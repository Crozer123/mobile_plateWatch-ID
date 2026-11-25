package com.example.platewatch

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread
import kotlin.math.PI
import kotlin.math.sin

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.example.platewatch/alarm"
        private const val SAMPLE_RATE = 44100
    }

    private val alarmLock = Any()
    @Volatile
    private var playing = false
    private var alarmThread: Thread? = null
    private var activeTrack: AudioTrack? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startAlarm" -> {
                        startAlarm()
                        result.success(true)
                    }
                    "stopAlarm" -> {
                        stopAlarm()
                        result.success(true)
                    }
                    "playWarningBeep" -> {
                        playWarningBeep()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun buildAlarmTrack(minBufBytes: Int): AudioTrack {
        val attrs = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        val format = AudioFormat.Builder()
            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
            .setSampleRate(SAMPLE_RATE)
            .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
            .build()
        return AudioTrack(
            attrs,
            format,
            minBufBytes,
            AudioTrack.MODE_STREAM,
            AudioManager.AUDIO_SESSION_ID_GENERATE,
        )
    }

    private fun synthTone(freqHz: Double, durationMs: Int, amplitude: Double = 0.85): ShortArray {
        val count = (SAMPLE_RATE * durationMs) / 1000
        val samples = ShortArray(count)
        val fadeSamples = (SAMPLE_RATE * 10) / 1000
        for (i in 0 until count) {
            val env = when {
                i < fadeSamples -> i.toDouble() / fadeSamples
                i > count - fadeSamples -> (count - i).toDouble() / fadeSamples
                else -> 1.0
            }
            val v = sin(2.0 * PI * freqHz * i / SAMPLE_RATE) * amplitude * env
            samples[i] = (v * Short.MAX_VALUE).toInt().coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt()).toShort()
        }
        return samples
    }

    private fun startAlarm() {
        synchronized(alarmLock) {
            if (playing) return
            playing = true
            alarmThread = thread(isDaemon = true, name = "PlateWatchAlarmThread") {
                val minBuf = AudioTrack.getMinBufferSize(
                    SAMPLE_RATE,
                    AudioFormat.CHANNEL_OUT_MONO,
                    AudioFormat.ENCODING_PCM_16BIT,
                ).coerceAtLeast(4096)

                var track: AudioTrack? = null
                try {
                    track = buildAlarmTrack(minBuf)
                    if (track.state != AudioTrack.STATE_INITIALIZED) {
                        track.release()
                        playing = false
                        return@thread
                    }
                    synchronized(alarmLock) { activeTrack = track }
                    val lowTone = synthTone(880.0, 260, 0.90)
                    val highTone = synthTone(1320.0, 260, 0.90)
                    track.play()

                    while (playing) {
                        if (!playing) break
                        track.write(highTone, 0, highTone.size)
                        if (!playing) break
                        track.write(lowTone, 0, lowTone.size)
                    }
                } catch (_: Throwable) {
                    playing = false
                } finally {
                    try {
                        track?.pause()
                        track?.flush()
                        track?.stop()
                    } catch (_: Throwable) {
                    }
                    try {
                        track?.release()
                    } catch (_: Throwable) {
                    }
                    synchronized(alarmLock) {
                        if (activeTrack === track) activeTrack = null
                    }
                }
            }
        }
    }

    private fun stopAlarm() {
        val threadToJoin: Thread?
        synchronized(alarmLock) {
            playing = false
            threadToJoin = alarmThread
            alarmThread = null
            try {
                activeTrack?.pause()
                activeTrack?.flush()
            } catch (_: Throwable) {
            }
        }
        try {
            threadToJoin?.join(400)
        } catch (_: Throwable) {
        }
    }

    private fun playWarningBeep() {
        thread(isDaemon = true, name = "PlateWatchWarnBeep") {
            val minBuf = AudioTrack.getMinBufferSize(
                SAMPLE_RATE,
                AudioFormat.CHANNEL_OUT_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
            ).coerceAtLeast(4096)
            var track: AudioTrack? = null
            try {
                track = buildAlarmTrack(minBuf)
                if (track.state != AudioTrack.STATE_INITIALIZED) {
                    track.release()
                    return@thread
                }
                val beep = synthTone(740.0, 120, 0.70)
                val gap = ShortArray((SAMPLE_RATE * 60) / 1000)
                track.play()
                track.write(beep, 0, beep.size)
                track.write(gap, 0, gap.size)
                track.write(beep, 0, beep.size)
                Thread.sleep(360)
            } catch (_: Throwable) {
            } finally {
                try {
                    track?.stop()
                    track?.release()
                } catch (_: Throwable) {
                }
            }
        }
    }

    override fun onDestroy() {
        stopAlarm()
        super.onDestroy()
    }
}

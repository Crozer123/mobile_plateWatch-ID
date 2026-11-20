import sqlite3
from datetime import datetime
from pathlib import Path
from typing import Optional

class ParkingService:
    def __init__(self, db_path: str = "parking.db"):
        self.db_path = db_path
        Path(self.db_path).parent.mkdir(parents=True, exist_ok=True)
        self._init_db()

    def _get_conn(self) -> sqlite3.Connection:
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        return conn

    def _init_db(self) -> None:
        with self._get_conn() as conn:
            conn.execute("""
                CREATE TABLE IF NOT EXISTS parking_logs (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    ticket_code TEXT UNIQUE NOT NULL,
                    plate_number TEXT NOT NULL,
                    entry_time TEXT NOT NULL,
                    exit_time TEXT,
                    entry_face_path TEXT,
                    exit_face_path TEXT,
                    entry_plate_path TEXT,
                    exit_plate_path TEXT,
                    similarity_score REAL,
                    status TEXT NOT NULL
                )
            """)
            conn.commit()

    def register_entry(
        self,
        plate_number: str,
        entry_face_path: Optional[str] = None,
        entry_plate_path: Optional[str] = None,
    ) -> dict:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        ticket_code = f"PK-{datetime.now().strftime('%H%M%S')}"

        with self._get_conn() as conn:
            conn.execute("""
                INSERT INTO parking_logs (
                    ticket_code, plate_number, entry_time,
                    entry_face_path, entry_plate_path, status
                ) VALUES (?, ?, ?, ?, ?, ?)
            """, (ticket_code, plate_number, now, entry_face_path, entry_plate_path, "ACTIVE"))
            conn.commit()

        return {
            "ticket_code": ticket_code,
            "plate_number": plate_number,
            "entry_time": now,
            "status": "ENTRY_SUCCESS",
            "ui_state": "Masuk Berhasil",
        }

    def verify_exit(
        self,
        plate_number: str,
        similarity_score: float,
        threshold: float = 0.75,
        exit_face_path: Optional[str] = None,
        exit_plate_path: Optional[str] = None,
    ) -> dict:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        with self._get_conn() as conn:
            row = conn.execute("""
                SELECT * FROM parking_logs
                WHERE plate_number = ? AND status = 'ACTIVE'
                ORDER BY id DESC LIMIT 1
            """, (plate_number,)).fetchone()

            if not row:
                return {
                    "ticket_code": None,
                    "plate_number": plate_number,
                    "similarity_score": similarity_score,
                    "status": "NEED_STAFF_CONFIRMATION",
                    "ui_state": "Konfirmasi Petugas",
                    "reason": "Data parkir aktif untuk plat ini tidak ditemukan",
                }

            is_match = similarity_score >= threshold
            new_status = "COMPLETED" if is_match else "REJECTED_MISMATCH"
            ui_state = "Keluar Cocok" if is_match else "Alarm Wajah Berbeda"

            conn.execute("""
                UPDATE parking_logs
                SET exit_time = ?, exit_face_path = ?, exit_plate_path = ?,
                    similarity_score = ?, status = ?
                WHERE id = ?
            """, (now, exit_face_path, exit_plate_path, similarity_score, new_status, row["id"]))
            conn.commit()

            return {
                "ticket_code": row["ticket_code"],
                "plate_number": plate_number,
                "entry_time": row["entry_time"],
                "exit_time": now,
                "similarity_score": round(similarity_score, 2),
                "status": new_status,
                "ui_state": ui_state,
            }

    def get_active_vehicles(self) -> list[dict]:
        with self._get_conn() as conn:
            rows = conn.execute("""
                SELECT ticket_code, plate_number, entry_time, status
                FROM parking_logs
                WHERE status = 'ACTIVE'
                ORDER BY id DESC
            """).fetchall()
            return [dict(r) for r in rows]

    def get_history_vehicles(self) -> list[dict]:
        with self._get_conn() as conn:
            rows = conn.execute("""
                SELECT ticket_code, plate_number, entry_time, exit_time, similarity_score, status
                FROM parking_logs
                WHERE status IN ('COMPLETED', 'REJECTED_MISMATCH')
                ORDER BY id DESC
            """).fetchall()
            return [dict(r) for r in rows]
from datetime import datetime, timezone

from sqlalchemy import select, delete

from app.Database.connection import SessionLocal
from app.Database.models import TrafficEvent


def _event_to_dict(event: TrafficEvent) -> dict:
    """Convert a database event into a dictionary."""

    return {
        "id": event.id,
        "intersection_id": event.intersection_id,
        "timestamp": event.timestamp.isoformat(),
        "vehicle_count": event.vehicle_count,
        "avg_speed": event.avg_speed,
        "queue_len": event.queue_len,
        "meta": event.event_meta or {},
    }


def add_event(event: dict) -> dict:
    """Store a new traffic event in PostgreSQL."""

    timestamp = datetime.fromisoformat(
        str(event["timestamp"]).replace("Z", "+00:00")
    )

    if timestamp.tzinfo is None:
        timestamp = timestamp.replace(tzinfo=timezone.utc)

    db_event = TrafficEvent(
        intersection_id=str(event["intersection_id"]),
        timestamp=timestamp,
        vehicle_count=int(event["vehicle_count"]),
        avg_speed=float(event["avg_speed"]),
        queue_len=int(event["queue_len"]),
        event_meta=event.get("meta") or {},
    )

    with SessionLocal() as session:
        session.add(db_event)
        session.commit()
        session.refresh(db_event)

        return _event_to_dict(db_event)


def get_recent_events(limit: int = 20) -> list[dict]:
    """Return the most recent events, newest first."""

    limit = max(0, int(limit))

    with SessionLocal() as session:
        statement = (
            select(TrafficEvent)
            .order_by(TrafficEvent.id.desc())
            .limit(limit)
        )

        events = session.scalars(statement).all()

        return [_event_to_dict(event) for event in events]


def clear_events():
    """Delete all traffic events."""

    with SessionLocal() as session:
        session.execute(delete(TrafficEvent))
        session.commit()
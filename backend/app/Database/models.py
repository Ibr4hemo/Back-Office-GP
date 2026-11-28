from datetime import datetime

from sqlalchemy import (
    Integer,
    String,
    Float,
    DateTime,
    JSON,
    CheckConstraint,
    text
)

from sqlalchemy.orm import (
    DeclarativeBase,
    Mapped,
    mapped_column
)


class Base(DeclarativeBase):
    pass


class TrafficEvent(Base):

    __tablename__ = "traffic_events"

    __table_args__ = (
        CheckConstraint(
            "vehicle_count >= 0",
            name="ck_traffic_events_vehicle_count_nonnegative"
        ),
        CheckConstraint(
            "avg_speed >= 0",
            name="ck_traffic_events_avg_speed_nonnegative"
        ),
        CheckConstraint(
            "queue_len >= 0",
            name="ck_traffic_events_queue_len_nonnegative"
        ),
    )

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True
    )

    intersection_id: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
        index=True
    )

    timestamp: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        index=True
    )

    vehicle_count: Mapped[int] = mapped_column(
        Integer,
        nullable=False
    )

    avg_speed: Mapped[float] = mapped_column(
        Float,
        nullable=False
    )

    queue_len: Mapped[int] = mapped_column(
        Integer,
        nullable=False
    )

    event_meta: Mapped[dict] = mapped_column(
        "meta",
        JSON,
        nullable=False,
        default=dict,
        server_default=text("'{}'")
    )

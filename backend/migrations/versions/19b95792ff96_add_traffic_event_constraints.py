"""add traffic event constraints

Revision ID: 19b95792ff96
Revises: 24680ebaeaeb
"""

from typing import Sequence, Union

from alembic import op


revision: str = '19b95792ff96'
down_revision: Union[str, Sequence[str], None] = '24680ebaeaeb'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_check_constraint(
        "ck_traffic_events_vehicle_count_nonnegative",
        "traffic_events",
        "vehicle_count >= 0"
    )

    op.create_check_constraint(
        "ck_traffic_events_avg_speed_nonnegative",
        "traffic_events",
        "avg_speed >= 0"
    )

    op.create_check_constraint(
        "ck_traffic_events_queue_len_nonnegative",
        "traffic_events",
        "queue_len >= 0"
    )


def downgrade() -> None:
    op.drop_constraint(
        "ck_traffic_events_queue_len_nonnegative",
        "traffic_events",
        type_="check"
    )

    op.drop_constraint(
        "ck_traffic_events_avg_speed_nonnegative",
        "traffic_events",
        type_="check"
    )

    op.drop_constraint(
        "ck_traffic_events_vehicle_count_nonnegative",
        "traffic_events",
        type_="check"
    )
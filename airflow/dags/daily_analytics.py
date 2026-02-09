"""
Daily Analytics Pipeline
Orchestrates the daily execution of dbt models for the e-commerce analytics platform.
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.utils.dates import days_ago

default_args = {
    'owner': 'analytics_team',
    'depends_on_past': False,
    'email': ['analytics@company.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

def check_data_freshness():
    """Check if source data is fresh enough to process"""
    print("Checking data freshness...")
    # Add your data freshness logic here
    return True

def send_success_notification():
    """Send notification on successful pipeline completion"""
    print("Pipeline completed successfully!")
    # Add notification logic (Slack, email, etc.)
    return True

with DAG(
    'daily_analytics_pipeline',
    default_args=default_args,
    description='Daily e-commerce analytics data pipeline',
    schedule_interval='0 2 * * *',  # Run at 2 AM daily
    start_date=days_ago(1),
    catchup=False,
    tags=['analytics', 'daily', 'dbt'],
) as dag:

    # Check data freshness
    check_freshness = PythonOperator(
        task_id='check_data_freshness',
        python_callable=check_data_freshness,
    )

    # Install dbt dependencies
    dbt_deps = BashOperator(
        task_id='dbt_deps',
        bash_command='cd /opt/dbt && dbt deps',
    )

    # Run staging models
    dbt_run_staging = BashOperator(
        task_id='dbt_run_staging',
        bash_command='cd /opt/dbt && dbt run --select staging',
    )

    # Test staging models
    dbt_test_staging = BashOperator(
        task_id='dbt_test_staging',
        bash_command='cd /opt/dbt && dbt test --select staging',
    )

    # Run intermediate models
    dbt_run_intermediate = BashOperator(
        task_id='dbt_run_intermediate',
        bash_command='cd /opt/dbt && dbt run --select intermediate',
    )

    # Run marts models
    dbt_run_marts = BashOperator(
        task_id='dbt_run_marts',
        bash_command='cd /opt/dbt && dbt run --select marts',
    )

    # Test all models
    dbt_test_all = BashOperator(
        task_id='dbt_test_all',
        bash_command='cd /opt/dbt && dbt test',
    )

    # Create snapshots
    dbt_snapshot = BashOperator(
        task_id='dbt_snapshot',
        bash_command='cd /opt/dbt && dbt snapshot',
    )

    # Generate documentation
    dbt_docs = BashOperator(
        task_id='dbt_docs_generate',
        bash_command='cd /opt/dbt && dbt docs generate',
    )

    # Send success notification
    notify_success = PythonOperator(
        task_id='send_success_notification',
        python_callable=send_success_notification,
    )

    # Define task dependencies
    check_freshness >> dbt_deps >> dbt_run_staging >> dbt_test_staging
    dbt_test_staging >> dbt_run_intermediate >> dbt_run_marts
    dbt_run_marts >> dbt_test_all >> dbt_snapshot
    dbt_snapshot >> dbt_docs >> notify_success

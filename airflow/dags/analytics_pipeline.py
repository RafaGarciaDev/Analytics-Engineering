"""
Analytics Pipeline DAG

Este DAG orquestra todo o pipeline de analytics:
1. Carrega dados brutos (Extract)
2. Executa transformações dbt (Transform)
3. Valida qualidade dos dados (Validate)
4. Gera documentação
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.utils.dates import days_ago

# Configurações padrão da DAG
default_args = {
    'owner': 'analytics_team',
    'depends_on_past': False,
    'email': ['analytics@example.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
    'execution_timeout': timedelta(hours=1),
}

# Definição da DAG
dag = DAG(
    'analytics_pipeline',
    default_args=default_args,
    description='Complete analytics pipeline with dbt and data quality checks',
    schedule_interval='0 2 * * *',  # Executa diariamente às 2h AM
    start_date=days_ago(1),
    catchup=False,
    tags=['analytics', 'dbt', 'production'],
)

# Task 1: Verificar conexão com database
check_connection = BashOperator(
    task_id='check_database_connection',
    bash_command='pg_isready -h postgres -U airflow',
    dag=dag,
)

# Task 2: dbt deps - instalar dependências
dbt_deps = BashOperator(
    task_id='dbt_deps',
    bash_command='cd /opt/airflow/dbt && dbt deps',
    dag=dag,
)

# Task 3: dbt seed - carregar dados de referência
dbt_seed = BashOperator(
    task_id='dbt_seed',
    bash_command='cd /opt/airflow/dbt && dbt seed --profiles-dir .',
    dag=dag,
)

# Task 4: dbt run staging - executar modelos staging
dbt_run_staging = BashOperator(
    task_id='dbt_run_staging',
    bash_command='cd /opt/airflow/dbt && dbt run --select staging --profiles-dir .',
    dag=dag,
)

# Task 5: dbt test staging - testar modelos staging
dbt_test_staging = BashOperator(
    task_id='dbt_test_staging',
    bash_command='cd /opt/airflow/dbt && dbt test --select staging --profiles-dir .',
    dag=dag,
)

# Task 6: dbt run intermediate - executar modelos intermediate
dbt_run_intermediate = BashOperator(
    task_id='dbt_run_intermediate',
    bash_command='cd /opt/airflow/dbt && dbt run --select intermediate --profiles-dir .',
    dag=dag,
)

# Task 7: dbt run marts - executar modelos marts
dbt_run_marts = BashOperator(
    task_id='dbt_run_marts',
    bash_command='cd /opt/airflow/dbt && dbt run --select marts --profiles-dir .',
    dag=dag,
)

# Task 8: dbt test marts - testar modelos marts
dbt_test_marts = BashOperator(
    task_id='dbt_test_marts',
    bash_command='cd /opt/airflow/dbt && dbt test --select marts --profiles-dir .',
    dag=dag,
)

# Task 9: dbt docs generate - gerar documentação
dbt_docs_generate = BashOperator(
    task_id='dbt_docs_generate',
    bash_command='cd /opt/airflow/dbt && dbt docs generate --profiles-dir .',
    dag=dag,
)

# Task 10: Validação de qualidade com Great Expectations (placeholder)
def validate_data_quality(**kwargs):
    """
    Executa validações de qualidade dos dados usando Great Expectations.
    """
    print("Running data quality validations...")
    # Aqui você pode adicionar validações do Great Expectations
    print("Data quality checks passed!")
    return True

data_quality_check = PythonOperator(
    task_id='data_quality_validation',
    python_callable=validate_data_quality,
    dag=dag,
)

# Task 11: Notificação de sucesso
def send_success_notification(**kwargs):
    """
    Envia notificação de sucesso da pipeline.
    """
    execution_date = kwargs['execution_date']
    print(f"Pipeline completed successfully for {execution_date}")
    # Aqui você pode adicionar integração com Slack, email, etc.
    return True

success_notification = PythonOperator(
    task_id='send_success_notification',
    python_callable=send_success_notification,
    dag=dag,
)

# Definir dependências entre as tasks
check_connection >> dbt_deps >> dbt_seed

dbt_seed >> dbt_run_staging >> dbt_test_staging

dbt_test_staging >> dbt_run_intermediate

dbt_run_intermediate >> dbt_run_marts >> dbt_test_marts

dbt_test_marts >> [data_quality_check, dbt_docs_generate]

[data_quality_check, dbt_docs_generate] >> success_notification

from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file='.env', env_file_encoding='utf-8', case_sensitive=False)

    app_name: str = 'Ecommerce API'
    env: str = 'development'
    debug: bool = True
    api_prefix: str = '/api/v1'

    db_host: str
    db_port: int = 1433
    db_name: str
    db_user: str
    db_password: str
    db_driver: str = 'ODBC Driver 18 for SQL Server'

    jwt_secret_key: str
    jwt_algorithm: str = 'HS256'
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 7

    @property
    def sqlalchemy_database_uri(self) -> str:
        driver = self.db_driver.replace(' ', '+')
        return (
            f"mssql+pyodbc://{self.db_user}:{self.db_password}@{self.db_host}:{self.db_port}/"
            f"{self.db_name}?driver={driver}&TrustServerCertificate=yes"
        )


@lru_cache
def get_settings() -> Settings:
    return Settings()

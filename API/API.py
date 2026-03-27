from fastapi import FastAPI, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
import datetime
import logging

# Setup logging zodat je in de terminal ziet wat er gebeurt
# 1. Logging configuratie
logging.basicConfig(
    level=logging.INFO,
    format="(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# 2. Database configuratie (SQLite)
SQLALCHEMY_DATABASE_URL = "sqlite:///./bibliotheek_data.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class DataEntry(Base):
    __tablename__ = "interne_data"
    id = Column(Integer, primary_key=True, index=True)
    systeem = Column(String)
    informatie = Column(String)
    tijdstip = Column(DateTime, default=datetime.datetime.now)
    
Base.metadata.create_all(bind=engine)

# 3. Validatie Schema
class DataSchema(BaseModel):
    systeem: str
    informatie: str

# 4. FastAPI applicatie
app = FastAPI(title="Bibliotheek Ingest Service")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 5. Routes met foutafhandeling
@app.post("/ingest", status_code=201)
def voeg_data_toe(item: DataSchema, db: Session = Depends(get_db)):
    logger.info(f"START INGEST: Data ontvangen van systeem: {item.systeem}")
    try:
        nieuwe_rij = DataEntry(
            systeem=item.systeem, 
            informatie=item.informatie,
            tijdstip=datetime.datetime.now()
        )  
        
        db.add(nieuwe_rij)
        db.commit()
        db.refresh(nieuwe_rij)
        
        # Logging: succesvolle actie loggen
        logger.info(f"SUCCES INGEST: Data succesvol toegevoegd met ID: {nieuwe_rij.id}")

        # Terugkoppeling: Gestandariseerd JSON-bericht
        return {
            "status": "succes",
            "message": "Data succesvol toegevoegd", 
            "id": nieuwe_rij.id,
            "tijdstip": nieuwe_rij.tijdstip
        }

    except Exception as e:
        # Foutafhandeling: voorkom crash, draai wijzigingen terug
        db.rollback()

        # Logging: Log de specifieke fout voor debugg doeleinden
        logger.error(f"ERROR: Database-fout opgestreden: {str(e)}")

        # Terugkoppeling: Stuur een 500 code naar het systeem
        raise HTTPException(
            status_code=500, 
            detail="Interne serverfout: De database kon de data niet verwerken."
        )

@app.get("/")
def home():
    logger.info("Home endpoint aangeroepen.")
    return {"bericht": "De bibliotheek interface is online en en robuust geconfigureerd."}
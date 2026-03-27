from fastapi import FastAPI, Depends
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
import datetime
import logging

# Setup logging zodat je in de terminal ziet wat er gebeurt
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 1. Database configuratie (SQLite)
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

# 2. Validatie Schema
class DataSchema(BaseModel):
    systeem: str
    informatie: str

# 3. FastAPI applicatie
app = FastAPI(title="Bibliotheek Ingest Service")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/ingest", status_code=201)
def voeg_data_toe(item: DataSchema, db: Session = Depends(get_db)):
    logger.info(f"Ontvangen data van systeem: {item.systeem}") # Logt in je terminal
    
    nieuwe_rij = DataEntry(
        systeem=item.systeem, 
        informatie=item.informatie,
        tijdstip=datetime.datetime.now()
    )  
    db.add(nieuwe_rij)
    db.commit()
    db.refresh(nieuwe_rij)
    return {"status": "Data succesvol toegevoegd", "id": nieuwe_rij.id}

@app.get("/")
def home():
    return {"bericht": "De bibliotheek interface is online en beveiligd."}
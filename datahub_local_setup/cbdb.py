import sqlalchemy
engine = sqlalchemy.create_engine("couchbase:///?User=root&Password=yuvraj&Server=http://mycouchbaseserver")
#base = sqlalchemy.ext.declarative.declarative_base()

if(engine):
    print("connected")
print("No")

# class Customer(base):
# 	__tablename__ = "Customer"
# 	FirstName = sqlalchemy.Column(sqlalchemy.String,primary_key=True)
# 	TotalDue = sqlalchemy.Column(sqlalchemy.String)
	
# factory = sessionmaker(bind=engine)
# session = factory()
# for instance in session.query(Customer).filter_by(FirstName="Bob"):
#     print("FirstName: ", instance.FirstName)
#     print("TotalDue: ", instance.TotalDue)  
#     print("---------")

# new_rec = Customer(FirstName="placeholder", FirstName="Bob")
# session.add(new_rec)
# session.commit()
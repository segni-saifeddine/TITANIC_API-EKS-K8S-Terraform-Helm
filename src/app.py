from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
import os

#This function is used to get the value of an environment var, and STOP EVERYTHING 
def get_env_variable(name):
    try:
        return os.environ[name]
    except KeyError:
        message = "Expected environment variable '{}' not set.".format(name)
        raise Exception(message)

# get env vars OR ELSE
POSTGRES_HOST = get_env_variable("POSTGRES_HOST") 
POSTGRES_USER = get_env_variable("POSTGRES_USER")
POSTGRES_PW = get_env_variable("POSTGRES_PW")
POSTGRES_DB = get_env_variable("POSTGRES_DB")


app = Flask(__name__)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)

DB_URL = 'postgresql+psycopg2://{user}:{pw}@{url}/{db}'.format(user=POSTGRES_USER,pw=POSTGRES_PW,url=POSTGRES_HOST,db=POSTGRES_DB)

app.config['SQLALCHEMY_DATABASE_URI'] = DB_URL
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)
migrate = Migrate(app, db)


#create a model that will define the data about our people:
class People(db.Model):
   __tablename__ = 'people'
   
   id = db.Column(db.Integer, primary_key= True)
   survived= db.Column(db.Integer , nullable= False)
   pclass= db.Column(db.Integer , nullable= False)
   name = db.Column(db.String(255), nullable= False) 
   sex = db.Column(db.String(120), nullable= False) 
   age = db.Column(db.Float , nullable= False)
   siblings_spouses_aboard  = db.Column(db.Integer , nullable= False)
   parents_children_aboard   = db.Column(db.Integer , nullable= False)
   fare = db.Column(db.Float , nullable=False)


   def __init__(self, survived , pclass , name , sex , age , siblings_spouses_aboard , parents_children_aboard , fare ):
     self.survived = survived
     self.pclass= pclass
     self.name= name
     self.sex= sex
     self.age= age
     self.siblings_spouses_aboard= siblings_spouses_aboard
     self.parents_children_aboard= parents_children_aboard
     self.fare= fare


# Creating and Reading people [POST method]
@app.route('/people', methods = ['POST'])
def create_newpeople():
  if request.is_json:
    survived= request.json['survived']
    pclass = request.json['pclass']
    name= request.json['name']
    sex= request.json['sex']
    age= request.json['age']
    siblings_spouses_aboard =request.json['siblings_spouses_aboard']
    parents_children_aboard =request.json['parents_children_aboard']
    fare= request.json['fare']
    newpeople=People(survived=survived , pclass=pclass , name=name , sex=sex , age=age , siblings_spouses_aboard=siblings_spouses_aboard , parents_children_aboard=parents_children_aboard , fare=fare )
    db.session.add(newpeople)
    db.session.commit()
    return jsonify({"success": True,"response":"newpeople added"})
  else:
         return {"error": "The request payload is not in JSON format"}
      


# To get all the people in the database: [Get method]
@app.route('/people', methods = ['GET'])
def getpets():
     all_people = []
     peoples = People.query.all()
     for people in peoples:
          results = {
                    "survived":people.survived,
                    "pclass":people.pclass,
                    "name":people.name,
                    "sex":people.sex ,
                    "age":people.age , 
                    "siblings_spouses_aboard":people.siblings_spouses_aboard ,
                    "parents_children_aboard":people.parents_children_aboard ,
                    "fare":people.fare , }
          all_people.append(results)

     return jsonify(all_people)
        


#To retrieve a single people [GET method]:
@app.route('/people/<id>', methods=['GET'])
def get_people(id):
       peoples= People.query.get(id)
       del peoples.__dict__['_sa_instance_state']
       return jsonify(peoples.__dict__)


#To update an existing item:[PUT method]
@app.route('/people/<id>', methods=['PUT'])
def update_item(id):
  body = request.get_json()
  db.session.query(People).filter_by(id=id).update(
    dict(survived=body['survived'], pclass=body['pclass'] , name=body['name'] , sex=body['sex'] , age=body['age'] , siblings_spouses_aboard=body['siblings_spouses_aboard'] , parents_children_aboard=body['parents_children_aboard'] , fare=body['fare']))
  db.session.commit()
  return "people udpdated"


#To delete an existing people:[DELETE method]
@app.route('/people/<id>', methods=['DELETE'])
def delete_people(id):
  db.session.query(People).filter_by(id=id).delete()
  db.session.commit()
  return "people deleted"




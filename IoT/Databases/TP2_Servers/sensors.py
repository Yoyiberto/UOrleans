from flask import Flask, jsonify, url_for, request
from flask_restx import Resource, Api, fields
import sqlite3

app = Flask(__name__)
api = Api(app)

cat_dict={
    1:{"catID":1,"catName":"compass"}
}

genid=2

categorypost=api.model('categorypost',{
    'catName':fields.String(example='Luxmeter',required=True)
    })

categoryget=api.model('categoryget',{
    'catID':fields.Integer(example=1,required=True),
    'catName':fields.String(example='Luxmeter',required=True)
    })


@api.route('/categories')
class Categories(Resource) :
    def get(self) :
        """ OK This is a get on all the categories that returns their name and location. Just try it."""
        dbname="my.db"
        conn=sqlite3.connect(dbname)
        curs=conn.cursor()
        details=[]
        for myrow in curs.execute("Select catID, catName FROM Category") :
            details.append({
                'catName': myrow[1],
                'location':url_for('categoriesget',catid=myrow[0])
            })
        return(jsonify(details))

    @api.doc(body=categorypost,model=categoryget)
    def post(self) :
        """ This is to add a new category blabla"""
        global genid
        # here is a new category object...
        category={}
        # i check that data has been sent is json
        if request.json :
            category['catID']=genid
            try :
                category['catName']=request.json['catName']
            except (KeyError, TypeError, ValueError) :
                abort(400) # bad request
            cat_dict[genid]=category
            response=jsonify(category)  # on crée avec la catégorie en body
            response.status_code=201 # created
            response.headers['location'] = url_for('categoriesget',catid=genid) # location de la nouvelle catégorie
            genid=genid+1 # increment du genid pour la prochaine catégorie (pas beau de le faire ici)
            return response # renvoi de la réponse complète
        else :
            abort(415)


@api.route('/categories/<catid>',endpoint='categoriesget')
class Categories(Resource) :
    def get(self,catid) :
        dbname="my.db"
        conn=sqlite3.connect(dbname)
        curs=conn.cursor()
        for myrow in curs.execute("Select catID, catName FROM Category WHERE catID=?", (catid,)) :
            category={
                'catID': myrow[0],
                'catName': myrow[1]
            }
        return(jsonify(myrow))



if __name__ == '__main__' :
    app.run(debug=True)
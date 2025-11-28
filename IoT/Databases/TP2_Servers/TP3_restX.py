from flask import Flask, jsonify, url_for, request
from flask_restx import Resource, Api, fields
app = Flask(__name__)
api = Api(app)

cat_dict={
    1:{"catID":1, "catName":"compass"}
}
genid=1

@api.route('/categories')
class Categories(Resource):
    def get(self): 
        details=[]
        for idc in cat_dict.keys():
            catName=cat_dict.get(idc).get('catname')
            details.append({
                'catName':catName,
                'location':url_for('categoriesget',catid=idc)
            })
        return(jsonify(details))
    def post(self):
        global genid

        categorie={}
        if request.json:
            categorie['catId']=genid
        try:
            categorie['catName']=request.json['intitule']
        except (KeyError,TypeError,ValueError):
            abort(400)
        cat_dict[genid]=categorie
        response=jsonify(categorie)
        response.status_code=201
        return(jsonify("Hello world"))

@api.route('/categories/<catid>', endpoint='categoriesget')
class Categories(Resource):
    def get(self): 
        return(jsonify("Hello world"))

if __name__=='__main__':
    app.run(debug=True)
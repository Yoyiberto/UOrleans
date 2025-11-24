from flask import Flask, jsonify, url_for,request,abort, render_template


app = Flask(__name__)



followed={
1: {'id':1,'firstname':'Albert','lastname':'Durand','tel':'0634231234','sick':False},
2: {'id':2,'firstname':'Simon','lastname':'Ricard','tel':'0978763423','sick':False},
3: {'id':3,'firstname':'Didier','lastname':'Raoult','tel':'0634768779','sick':False}
}

contacts={1: [2,3], 2: [1], 3: [1]}

genid_fol=4


@app.route('/')
def index():
    return('<h1>Welcome to Epidemy.</h1>'
    '<p>This REST service will show you how to query REST services with various tools.</p>'
    '<p>Remember than REST services can be queried with the standard HTTP methods :</p>'
    '<p>GET/POST/PUT/PATCH/DELETE</p>'
    '<p>First, go to http://localhost:5000/followed</p>')

@app.route('/followed',methods=['GET'])
def inscritsGet():
    return(jsonify(tuple(followed)))

@app.route('/followed/<folid>',methods=['GET'])
def inscritsGetId(folid):
    return(jsonify({'abonne':followed[int(folid)]}))

@app.route('/followed',methods=['POST'])
def inscritsPost():
    global genid_fol
    nfol={
    'firstname':request.json['firstname'],
    'lastname':request.json['lastname'],
    'tel':request.json['tel']
     }
    rank=genid_fol
    genid_fol=genid_fol+1
    nfol['id']=rank
    nfol['sick']=False
    followed[rank]=nfol
    response=jsonify(nfol)
    response.status_code=201
    response.headers['location'] = url_for('inscritsPost')+'/'+str(rank)
    return response

@app.route('/followed/<folid>',methods=['PATCH'])
def inscritsPatch(folid):
    fol=followed[int(folid)]
    if (not request.is_json) :
        response=jsonify("This PATCH method expects the value of sick attribute (boolean), transfered in JSON format.")
        response.status_code=415
        return (response)
    else :
        try :
            fol['sick']=request.json['sick']
            response=jsonify(fol)
            response.status_code=200
            response.headers['location'] = '/followed/'+str(folid)+'/'+str(folid)
            return response
        except(KeyError,TypeError,ValueError) :
            response=jsonify("This PATCH method expects the value of 'sick' attribute (boolean), transfered in JSON format.")
            response.status_code=400
            return (response)          

@app.route('/followed/<folid>',methods=['PUT'])
def inscritsPut(folid):
    fol=followed[int(folid)]
    if (not request.mimetype=='application/x-www-form-urlencoded') :
        response=jsonify("This PUT method expects the FORM format, not the JSON format.")
        response.status_code=415
        return (response)
    try:
        nom=request.form['lastname']
        prenom=request.form['firstname']
        tel=request.form['tel']
    except (KeyError, TypeError, ValueError):
        response=jsonify('Missing mandatory fields')
        response.status_code=400
        return response
    fol['lastname']=nom
    fol['firstname']=prenom
    fol['tel']=tel
    try:
        fol['sick']=bool(request.form['sick'])
    except (KeyError, TypeError, ValueError):
        fol['sick']=False
    response=jsonify(fol)
    response.status_code=200
    response.headers['location'] = '/followed/'+str(folid)
    return response


@app.route('/followed/<folid>/contacts',methods=['GET'])
def contactsGet(folid):
    i_folid=int(folid)
    co=contacts.get(i_folid,[])
    return(jsonify(co))


@app.route('/followed/<folid>/contacts',methods=['POST'])
def contactsPost(folid):
    i_folid=int(folid)
    co=contacts.get(i_folid,[])
    i_contid=int(request.json['contid'])
    co.append(i_contid)
    contacts[i_folid]=co
    #rank=contacts[i_folid]
    response=jsonify(i_contid)
    response.headers['location'] = '/followed/'+str(folid)+'/contacts/'+str(i_contid)
    response.status_code=201
    return response

@app.route('/followed/<folid>/contacts/<contid>',methods=['DELETE'])
def contactsDelete(folid,contid):
    i_folid=int(folid)
    i_contid=int(contid)
    co=contacts.get(i_folid,[])
    print(co)
    print(i_contid)
    if (i_contid in co):
        co.remove(i_contid)
    contacts[i_folid]=co
    return('deleted',200)

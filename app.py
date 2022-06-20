from flask import Flask, render_template, request, redirect, url_for, flash
from flask_mysqldb import MySQL

app = Flask(__name__)

# MYSQL Connection
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'test'
app.config['MYSQL_PASSWORD'] = 'test'
app.config['MYSQL_DB'] = 'fonasa'
mysql = MySQL(app)

# Settings
app.secret_key = 'mysecretkey'

@app.route('/')
def index():
    cursor = mysql.connection.cursor()
    cursor.execute('SELECT * FROM hospitales')
    data = cursor.fetchall()

    return render_template('index.html', hospitales = data)

@app.route('/nuevoHospital')
def nuevoHospital():
    return render_template('add_hospital.html')

@app.route('/addHospital', methods=['POST'])
def addHospital():
    if request.method == 'POST':
        nombreHospital = request.form['nombreHospital']
        
        cursor = mysql.connection.cursor()
        cursor.execute("INSERT INTO hospitales (nombreHospital) VALUES (%s)", [nombreHospital])
        mysql.connection.commit()

        #flash('Hospital agregado con éxito')
        return redirect(url_for('index'))

@app.route('/addPaciente', methods=['POST'])
def addPaciente():
    if request.method == 'POST':
        runPaciente = request.form['runPaciente']
        nombrePaciente = request.form['nombrePaciente']
        fechaNacimientoPaciente = request.form['fechaNacimientoPaciente']
        idHospital = request.form['idHospital']
        relacionPesoEstatura = request.form['relacionPesoEstatura']
        pacienteFumador = request.form['pacienteFumador']
        anniosFumador = request.form['anniosFumador']
        pacienteDieta = request.form['pacienteDieta']
        tipoPersona = request.form['tipoPersona']
        
        match tipoPersona:
            case ('niño'):
                print(tipoPersona)
                cursorNinno = mysql.connection.cursor()
                cursorNinno.execute("""INSERT INTO pacientes 
                (runPaciente, nombrePaciente, fechaNacimientoPaciente, idHospital) 
                VALUES (%s,%s,%s,%s)""", [runPaciente, nombrePaciente, fechaNacimientoPaciente, idHospital])
                mysql.connection.commit()
            case ('joven'):
                print(tipoPersona)
                cursorJoven = mysql.connection.cursor()
                cursorJoven.execute("""INSERT INTO pacientes 
                (runPaciente, nombrePaciente, fechaNacimientoPaciente, idHospital) 
                VALUES (%s,%s,%s,%s)""", [runPaciente, nombrePaciente, fechaNacimientoPaciente, idHospital])
                mysql.connection.commit()
            case _:
                print(tipoPersona)
            
    #flash('Paciente agregado con éxito')
    return redirect(url_for('index'))


       

        
@app.route('/hospital/<id>')
def view(id):
    cursor = mysql.connection.cursor()
    cursor.execute('SELECT * FROM hospitales WHERE idHospital = {0}'.format(id))
    data = cursor.fetchall()

    cursor2 = mysql.connection.cursor()
    cursor2.execute('SELECT * FROM hospitales')
    data2 = cursor2.fetchall()

    return render_template('hospital_details.html', hospital = data[0], hospitales = data2)

@app.route('/listarPacientes')
def listarPacientes():
    cursor = mysql.connection.cursor()
    cursor.execute("""SELECT numeroHistoriaClinicaPaciente,
        nombrePaciente, 
        fechaNacimientoPaciente, 
        TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) AS edadPaciente
        FROM pacientes""")
    data = cursor.fetchall()

    return render_template('listar_pacientes.html', pacientes = data)



if __name__ == '__main__':
    app.run(port = 3000, debug = True)
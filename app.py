# -*- coding: utf-8 -*-
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

    return render_template('index.html', hospitales=data)


@app.route('/nuevoHospital')
def nuevoHospital():
    return render_template('add_hospital.html')


@app.route('/addHospital', methods=['POST'])
def addHospital():
    if request.method == 'POST':
        nombreHospital = request.form['nombreHospital']

        cursor = mysql.connection.cursor()
        cursor.execute("INSERT INTO hospitales (nombreHospital) VALUES (%s)", [
                       nombreHospital])
        mysql.connection.commit()

        #flash('Hospital agregado con éxito')
        return redirect(url_for('index'))

@app.route('/updateAtenderPaciente', methods=['POST'])
def updateAtenderPaciente():
    if request.method == 'POST':
        numeroHistoriaClinicaPacienteModal = request.form['numeroHistoriaClinicaPacienteModal']

        cursor = mysql.connection.cursor()
        cursor.execute("UPDATE pacientes SET estado = 'atendido' WHERE numeroHistoriaClinicaPaciente = %s", [numeroHistoriaClinicaPacienteModal])
        mysql.connection.commit()
        #flash('Hospital agregado con éxito')
        return redirect(url_for('index'))


@app.route('/addConsulta', methods=['POST'])
def addConsulta():
    if request.method == 'POST':
        idHospital = request.form['idHospital']
        runEspecialista = request.form['runEspecialista']
        nombreEspecialista = request.form['nombreEspecialista']
        idTipoConsulta = request.form['idTipoConsulta']

        cursor = mysql.connection.cursor()
        cursor.execute("""INSERT INTO consultas 
        (idHospital, runEspecialista, nombreEspecialista, idTipoConsulta, estado) 
        VALUES (%s,%s,%s,%s,'En Espera')""", [idHospital, runEspecialista, nombreEspecialista, idTipoConsulta])
        mysql.connection.commit()

        flash('Consulta agregada con éxito')
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
        tipoPaciente = request.form['tipoPaciente']
        prioridad = request.form['prioridad']

        match tipoPaciente:
            case ('niño'):
                print(tipoPaciente)
                cursorNinno = mysql.connection.cursor()
                cursorNinno.execute("""INSERT INTO pacientes 
                (runPaciente, nombrePaciente, fechaNacimientoPaciente, idHospital, relacionPesoEstatura, prioridad, tipoPaciente, estado) 
                VALUES (%s,%s,%s,%s,%s,%s,%s,'En Espera')""", [runPaciente, nombrePaciente, fechaNacimientoPaciente, idHospital, relacionPesoEstatura, prioridad, tipoPaciente])
                mysql.connection.commit()
            case ('joven'):
                print(tipoPaciente)
                cursorJoven = mysql.connection.cursor()
                cursorJoven.execute("""INSERT INTO pacientes 
                (runPaciente, nombrePaciente, fechaNacimientoPaciente, idHospital, pacienteFumador, anniosFumador, prioridad, tipoPaciente, estado) 
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,'En Espera')""", [runPaciente, nombrePaciente, fechaNacimientoPaciente, idHospital, pacienteFumador, anniosFumador, prioridad, tipoPaciente])
                mysql.connection.commit()
            case _:
                print(tipoPaciente)
                cursorAnciano = mysql.connection.cursor()
                cursorAnciano.execute("""INSERT INTO pacientes 
                (runPaciente, nombrePaciente, fechaNacimientoPaciente, idHospital, pacienteDieta, prioridad, tipoPaciente, estado) 
                VALUES (%s,%s,%s,%s,%s,%s,%s,'En Espera')""", [runPaciente, nombrePaciente, fechaNacimientoPaciente, idHospital, pacienteDieta, prioridad, tipoPaciente])
                mysql.connection.commit()

    flash('Paciente agregado con éxito')
    return redirect(url_for('listarPacientes'))


@app.route('/hospital/<id>')
def hospital(id):
    cursorHospitalDetails = mysql.connection.cursor()
    cursorHospitalDetails.execute(
        'SELECT * FROM hospitales WHERE idHospital = {0}'.format(id))
    data = cursorHospitalDetails.fetchall()

    cursorConsultas = mysql.connection.cursor()
    cursorConsultas.execute("""SELECT idHospital, runEspecialista, nombreEspecialista, nombreTipoConsulta, estado 
    FROM consultas AS c
    INNER JOIN tipoconsulta AS t ON c.idTipoConsulta = t.idTipoConsulta 
    WHERE idHospital = {0}""".format(id))
    dataConsultas = cursorConsultas.fetchall()

    return render_template('hospital_detalle.html', hospital=data[0], consultas=dataConsultas)


@app.route('/atenderPaciente/<runEspecialista>/<idHospital>')
def atenderPaciente(runEspecialista, idHospital):
    print(runEspecialista, idHospital)

    cursoratenderPaciente = mysql.connection.cursor()
    sqlSelectProcedure = 'call atenderPacientes(%s, %s)'
    valores = (runEspecialista, idHospital)

    cursoratenderPaciente.execute(sqlSelectProcedure, valores)
    data = cursoratenderPaciente.fetchall()

    return render_template('atender_paciente.html', pacientes=data)

@app.route('/listarPacientesFumadores')
def listarPacientesFumadores():
    cursor = mysql.connection.cursor()
    cursor.execute("""SELECT numeroHistoriaClinicaPaciente,
        nombrePaciente,
        'SI' AS pacienteFumadador,
        fechaNacimientoPaciente, 
        TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) AS edadPaciente,
        prioridad,
        IF(tipoPaciente= 'anciano', ((TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) * prioridad)/100 +5.3), ((TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) * prioridad) /100) ) AS riesgo,
        h.nombreHospital
        FROM pacientes AS p
        INNER JOIN hospitales AS h ON p.idHospital = h.idHospital
        WHERE pacienteFumador = 1
        ORDER BY riesgo DESC""")
    data = cursor.fetchall()
    return render_template('listar_pacientes_fumadores.html', pacientes=data)

@app.route('/listarPacientesMayorRiesgo')
def listarPacientesMayorRiesgo():
    cursor = mysql.connection.cursor()
    cursor.execute("""SELECT numeroHistoriaClinicaPaciente,
        nombrePaciente, 
        fechaNacimientoPaciente, 
        TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) AS edadPaciente,
        prioridad,
        IF(tipoPaciente= 'anciano', ((TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) * prioridad)/100 +5.3), ((TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) * prioridad) /100) ) AS riesgo,
        h.nombreHospital
        FROM pacientes AS p
        INNER JOIN hospitales AS h ON p.idHospital = h.idHospital
        ORDER BY riesgo DESC""")
    data = cursor.fetchall()
    return render_template('listar_pacientes_riesgo.html', pacientes=data)

@app.route('/listarPacientesAncianos')
def listarPacientesAncianos():
    cursor = mysql.connection.cursor()
    cursor.execute("""SELECT numeroHistoriaClinicaPaciente,
        nombrePaciente, 
        fechaNacimientoPaciente, 
        TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) AS edadPaciente,
        prioridad,
        IF(tipoPaciente= 'anciano', ((TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) * prioridad)/100 +5.3), ((TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) * prioridad) /100) ) AS riesgo,
        h.nombreHospital
        FROM pacientes AS p
        INNER JOIN hospitales AS h ON p.idHospital = h.idHospital
        WHERE tipoPaciente = 'anciano' AND estado = 'En Espera'
        ORDER BY edadPaciente DESC""")
    data = cursor.fetchall()
    return render_template('listar_pacientes_ancianos.html', pacientes=data)


@app.route('/listarPacientes')
def listarPacientes():
    cursor = mysql.connection.cursor()
    cursor.execute("""SELECT numeroHistoriaClinicaPaciente,
        nombrePaciente, 
        fechaNacimientoPaciente, 
        TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) AS edadPaciente,
        prioridad,
        IF(tipoPaciente= 'anciano', ((TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) * prioridad)/100 +5.3), ((TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) * prioridad) /100) ) AS riesgo,
        h.nombreHospital
        FROM pacientes AS p
        INNER JOIN hospitales AS h ON p.idHospital = h.idHospital
        ORDER BY numeroHistoriaClinicaPaciente DESC""")
    data = cursor.fetchall()

    cursorHospitales = mysql.connection.cursor()
    cursorHospitales.execute('SELECT * FROM hospitales')
    dataHospitales = cursorHospitales.fetchall()

    return render_template('listar_pacientes.html', pacientes=data, hospitales=dataHospitales)


if __name__ == '__main__':
    app.run(host='0.0.0.0',port=3000, debug=True)

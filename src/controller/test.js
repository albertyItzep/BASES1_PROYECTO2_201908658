const script = require("../db/script")

const db = require("../db/conection")

exports.testModel = async(req, res) =>{
    try {
        const sqlCommands = script.split(";").map(command => command.trim());
        for(let i = 0; i< sqlCommands.length; i++){
            const element = sqlCommands[i];
            if (element.length === 0){
                continue
            }
            await db.query(element,[])
        }

        res.status(200).json({
            body: { res: true, message: 'MODELO CREADO CON EXITO'}, 
        })
    } catch (err) {
        res.status(500).json({ body: { res: false, message: 'OCURRIÓ UN PROBLEMA AL CREAR EL MODELO', err  },})
    }
}
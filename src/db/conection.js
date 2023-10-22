const mysql = require("mysql2/promise")
const config = require("./config")

async function query(sql,params){
    const conection = await mysql.createConnection(config.db)
    const [result,] = await conection.execute(sql,params)
    conection.end((err)=>{
        if (err) {
            return console.log("error de conexion: ",err.message)
        }
        console.log("Conexion cerrada exitosamente")
    })
    conection.destroy()
    return result;
}

async function queryWithoutClose(conection,sql,params) {
    const [result,] = await conection.execute(sql,params)
    return result
}

module.exports = {query,queryWithoutClose}
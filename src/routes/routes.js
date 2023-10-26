const express = require("express")

const {testModel} = require("../controller/test")
const router = express.Router()
// tenemos que realizar la carga masiva para que nos cargue los datos dentro de la base
router.get("/test",testModel)

module.exports = router; 

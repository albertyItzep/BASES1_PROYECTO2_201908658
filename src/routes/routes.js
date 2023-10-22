const express = require("express")

const {testModel} = require("../controller/test")
const router = express.Router()

router.get("/test",testModel)

module.exports = router;
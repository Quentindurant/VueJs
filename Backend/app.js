const express = require('express')
const cors    = require('cors')
require('dotenv').config()

const app  = express()
const PORT = process.env.PORT || 3000

app.use(cors())
app.use(express.json())

// Routes
const apiRouter = require('./routes/api')
app.use('/api', apiRouter)

app.listen(PORT, () => {
  console.log(`🚀 API démarrée sur http://localhost:${PORT}`)
})

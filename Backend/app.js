import express from 'express'
import cors from 'cors'
import 'dotenv/config'
import apiRouter from './routes/api.js'

const app  = express()
const PORT = process.env.PORT || 3000

app.use(cors())
app.use(express.json())

// Routes
app.use('/api', apiRouter)

app.listen(PORT, () => {
  console.log(`🚀 API démarrée sur http://localhost:${PORT}`)
})

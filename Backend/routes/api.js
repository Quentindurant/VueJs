import express from 'express'
import prisma from '../lib/prisma.js'

const router = express.Router()

// Health check
router.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() })
})


router.get('/courses', async (req, res) => {
  try {
    const courses = await prisma.course.findMany()
    res.json(courses)
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
})


router.get('/courses/:id', async (req, res) => {
  try {
    const course = await prisma.course.findUnique({
      where: { id: parseInt(req.params.id) }
    })
    if (!course) return res.status(404).json({ error: 'Cours non trouvé' })
    res.json(course)
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
})


router.post('/courses', async (req, res) => {
  try {
    const { title, price, instructor } = req.body
    const course = await prisma.course.create({
      data: { title, price: parseFloat(price), instructor }
    })
    res.status(201).json(course)
  } catch (err) {
    res.status(400).json({ error: err.message })
  }
})


router.put('/courses/:id', async (req, res) => {
  try {
    const { title, price, instructor } = req.body
    const course = await prisma.course.update({
      where: { id: parseInt(req.params.id) },
      data: { title, price: parseFloat(price), instructor }
    })
    res.json(course)
  } catch (err) {
    res.status(400).json({ error: err.message })
  }
})


router.delete('/courses/:id', async (req, res) => {
  try {
    await prisma.course.delete({
      where: { id: parseInt(req.params.id) }
    })
    res.json({ message: 'Cours supprimé' })
  } catch (err) {
    res.status(400).json({ error: err.message })
  }
})

export default router

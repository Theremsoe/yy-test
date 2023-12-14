import 'express-async-errors'
import express, { Express } from 'express';
import multer from 'multer'
import { create } from '../app/controllers/invoice';
import errorHandler from '../app/exceptions/error_handler';

const storage = multer.memoryStorage()
const upload = multer({ storage })

const app: Express = express()

app.post('/', upload.single('invoice'), create)
app.use(errorHandler)

export default app

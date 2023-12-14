import app from './bootstrap/server';
import './bootstrap/environment'

const port: number = Number.parseInt(process.env.PORT || '8000', 10);

app.listen(port, () => console.info(`[server]: Server is running at http://localhost:${port}`))

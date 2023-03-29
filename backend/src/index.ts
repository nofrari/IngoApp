import express from 'express';
import usersRouter from './routes/users';

const app = express();
app.use(express.json());

app.post('/', (req, res) => {
    res.status(201).send('Hello world');
});

app.use(usersRouter);

app.listen(3000);



import express from 'express';
import usersRouter from './routes/users';

const app = express();
app.use(express.json());

app.post('/', (req, res) => {
    res.status(201).send('Hello world');
});

app.use(usersRouter);

app.listen(5432);

//just for testing
export function add(first: number, second: number) {
    if (first === 0 || second === 0) {
        throw new Error();
    }
    return first + second;
}



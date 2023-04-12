import express from 'express';
import multer from 'multer';
const mindee = require("mindee");
import path from 'path';

import usersRouter from './routes/users';

const app = express();
const mindeeClient = new mindee.Client({ apiKey: "408ec2ab38cadbb87b1d5b976e3644b9" });

app.use(express.json());
app.use(usersRouter);

var storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, __dirname + "/uploads");
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + path.extname(file.originalname));
    }
});
const upload = multer({ storage: storage });

app.post('/', (req, res) => {
    res.status(201).send('Hello world');
});

app.post("/upload", upload.single("image"), (req, res) => {
    if (req.file === undefined || req.file === null) {
        return res.status(422).send("Image cannot be empty");
    }
    let file = req.file;

    //mindee parser
    const apiResponse = mindeeClient
        .docFromPath("./src/uploads/" + file?.filename)
        .parse(mindee.InvoiceV4);


    apiResponse.then((resp: { document: any; }) => {
        console.log(resp.document);
    });

    return res.status(200).send({ name: file?.filename });
});

app.listen(5432, () => {
    console.log("Listening on Port 3000!");
});

//just for testing
export function add(first: number, second: number) {
    if (first === 0 || second === 0) {
        throw new Error();
    }
    return first + second;
}



import { randomInt } from 'crypto';
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

type Invoicedata = {
    total_amount: number;
    date: string;
    supplier_name: string;
}

app.post("/scanner/upload", upload.single("image"), (req, res) => {
    console.log("request made");
    if (req.file === undefined || req.file === null) {
        return res.status(422).send("Image cannot be empty");
    }
    const foldername: string = Date.now().toString() + randomInt + "/";

    let file = req.file;

    //Uncomment mindee code again when testing invoice data

    //mindee parser
    const apiResponse = mindeeClient
        .docFromPath("./src/uploads/" + file?.filename)
        .parse(mindee.ReceiptV4);

    var invoicedata: Invoicedata = {
        total_amount: 0,
        date: "",
        supplier_name: ""
    };

    apiResponse.then((resp: { document: any; }) => {
        // invoicedata.total_amount = resp.document.totalAmount.value;
        // invoicedata.date = resp.document.date.value;
        // invoicedata.supplier_name = resp.document.supplierName.value;
        console.log(resp.document);
        console.log(invoicedata);
    }).then(() => {
        return res.status(200).send({ name: file?.filename, invoice_data: invoicedata });
    }).catch((err: any) => { console.log(err.toString()) });
});

app.listen(5432, () => {
    console.log("Listening on Port 5432!");
});

//just for testing
export function add(first: number, second: number) {
    if (first === 0 || second === 0) {
        throw new Error();
    }
    return first + second;
}



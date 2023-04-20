import { randomInt } from 'crypto';
import express from 'express';
import multer from 'multer';
const mindee = require("mindee");
import path from 'path';
import { Request, Response } from 'express';
import { FileArray, UploadedFile } from 'express-fileupload'
const fs = require('fs');
const imgToPDF = require('image-to-pdf');
import usersRouter from './routes/users';

const app = express();
const mindeeClient = new mindee.Client({ apiKey: "408ec2ab38cadbb87b1d5b976e3644b9" });

app.use(express.json());
app.use(usersRouter);

var storage =
    multer.diskStorage({
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

const PDFDocument = require('pdfkit');
const sharp = require('sharp');


async function createPDF(pages: String[]) {
    const doc = new PDFDocument({ margin: 0 });

    for (let index = 0; index < pages.length; index++) {
        const image = await sharp(pages[index])
            .rotate(90)
            .toBuffer();

        const imgSize = await sharp(image).metadata();
        doc.page.width = imgSize.width;
        doc.page.height = imgSize.height;

        doc.image(image, 0, 0, { fit: [imgSize.width, imgSize.height], align: 'center', valign: 'center' });

        if (pages.length != index + 1) doc.addPage()
    }

    doc.end()

    return doc
};

app.post("/scanner/upload", upload.array("image"), async (req, res) => {
    console.log("request made");
    if (!req.files || req.files.length === 0) {
        return res.status(422).send("At least one image is required");
    }

    let files = req.files as any;
    console.log("files: ", files);
    let filename = files[0].filename;
    const foldername: string = Date.now().toString() + randomInt + "/";

    //create pdf from images
    const pages: String[] = files.map((file: any) => "./src/uploads/" + file.filename);
    var pdf = await createPDF(pages);
    pdf.pipe(fs.createWriteStream("./src/uploads/invoice.pdf"));
    //imgToPDF(pages, [595.28, 419.53]).pipe(fs.createWriteStream("./src/uploads/invoice.pdf"));


    //Uncomment mindee code again when testing invoice data

    //mindee parser
    // const apiResponse = mindeeClient.fileupload
    //     .docFromPath("./src/uploads/" + filename)
    //     .parse(mindee.ReceiptV4);

    var invoicedata: Invoicedata = {
        total_amount: 0,
        date: "",
        supplier_name: ""
    };

    // apiResponse.then((resp: { document: any; }) => {
    // invoicedata.total_amount = resp.document.totalAmount.value;
    // invoicedata.date = resp.document.date.value;
    // invoicedata.supplier_name = resp.document.supplierName.value;
    //     console.log(resp.document);
    console.log(invoicedata);
    //   }).then(() => {
    return res.status(200).send({ name: files.length, invoice_data: invoicedata });
    //    }).catch((err: any) => { console.log(err.toString()) });
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



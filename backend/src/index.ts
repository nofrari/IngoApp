import { randomInt } from 'crypto';
import express from 'express';
import multer from 'multer';
const mindee = require("mindee");
import path from 'path';
import { Request, Response } from 'express';
import { FileArray, UploadedFile } from 'express-fileupload'
import usersRouter from './routes/users';
import fs from 'fs';
import PDFDocument from 'pdfkit';
import sharp from 'sharp';

//const fs = require('fs');
//const imgToPDF = require('image-to-pdf');
// const PDFDocument = require('pdfkit');
// const sharp = require('sharp');

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
    category: string;
}

async function createPDF(pages: String[]) {
    const doc = new PDFDocument({ margin: 0 });
    if (pages.length != 0) {
        for (let index = 0; index < pages.length; index++) {
            const path: string = pages[index].toString();
            const image = await sharp(path)
                .rotate(90)
                .toBuffer();

            const imgSize = await sharp(image).metadata();
            if (imgSize == null) throw new Error("Image size is null");
            doc.page.width = imgSize.width!;
            doc.page.height = imgSize.height!;

            doc.image(image, 0, 0, { fit: [imgSize.width!, imgSize.height!], align: 'center', valign: 'center' });

            if (pages.length != index + 1) doc.addPage()
        }

    } else {
        throw new Error("No pages found");
    }
    doc.end()
    return doc
};

// function getTotalHeight(pdfDoc: typeof PDFDocument): number {
//     let totalHeight = 0;
//     for (let i = 0; i < pdfDoc.pages.length; i++) {
//       totalHeight += pdfDoc.pages[i].getHeight();
//     }
//     return totalHeight;
//   }

app.post("/scanner/upload", upload.array("image"), async (req, res) => {
    if (!req.files || req.files.length === 0) {
        return res.status(422).send("At least one image is required");
    }

    let files = req.files as any;


    //scan first image
    var invoicedata: Invoicedata = {
        total_amount: 0,
        date: "",
        supplier_name: "",
        category: ""
    };

    const testResponse = new Promise((resolve, reject) => {
        resolve({
            document: {
                totalAmount: { value: 100 },
                date: { value: "2021-01-01" },
                supplier: { value: "Test" },
                category: { value: "Test" }
            },
        });
    })

    //mindee parser
    // const apiResponse = mindeeClient
    //     .docFromPath("./src/uploads/" + files[0].filename)
    //     .parse(mindee.ReceiptV4);

    testResponse.then((resp: any) => {
        console.log(resp);
        //Using Invoice
        // invoicedata.total_amount = resp.document.totalAmount.value;
        // invoicedata.date = resp.document.date.value;
        // invoicedata.supplier_name = resp.document.supplierName.value;
        // invoicedata.category = "";

        //Using Receipt
        invoicedata.total_amount = resp.document.totalAmount.value;
        invoicedata.date = resp.document.date.value;
        invoicedata.supplier_name = resp.document.supplier.value;
        invoicedata.category = resp.document.category.value;

        //console.log(resp);
        //console.log(invoicedata);
    }).then(async () => {
        try {
            const pdfname: string = Date.now().toString();

            //create pdf from images
            const pages: String[] = files.map((file: any) => "./src/uploads/" + file.filename);
            var pdf = await createPDF(pages);
            pdf.page
            pdf.pipe(fs.createWriteStream("./src/uploads/" + pdfname + ".pdf")).on('finish', async () => {
                const data = {
                    supplier_name: invoicedata.supplier_name,
                    total_amount: invoicedata.total_amount,
                    date: invoicedata.date,
                    category: invoicedata.category,
                    pdf_name: pdfname,
                    pdf: await fs.promises.readFile("./src/uploads/" + pdfname + ".pdf", { encoding: 'base64' }),
                    pdf_height: pdf.page.height * pages.length
                }
                console.log(pdf.page.height * pages.length);
                //delete images
                files.forEach((file: any) => {
                    fs.unlinkSync("./src/uploads/" + file.filename);
                });

                //console.log(data);
                res.setHeader('Content-Type', 'application/json');
                return res.status(200).send(JSON.stringify(data));
            });
        } catch (error) {
            console.log("Fehler beim PDF auslesen", error);
        }
    }).catch((err: any) => {
        console.log(err.toString()); throw new Error("Error parsing invoice data");
    });
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



const mindee = require("mindee");
// for TS or modules:
// import * as mindee from "mindee";

// Init a new client
const mindeeClient = new mindee.Client({ apiKey: "408ec2ab38cabb87b1d5b976e3644b9" });

// Load a file from disk and parse it
const invoiceResponse = mindeeClient
    .docFromPath("../credit_note.pdf")
    .parse(mindee.InvoiceV3);

// Print a the parsed data
invoiceResponse.then((resp) => {

    // The document property can be undefined:
    // * TypeScript will throw an error without this guard clause
    //   (or consider using '?' notation)
    // * JavaScript will be very happy to produce subtle bugs
    //   without this guard clause
    if (resp.document === undefined) return;

    // full object
    console.log(resp.document);

    // string summary
    console.log(resp.document.toString());
});


/*const http = require('http');

const hostname = '127.0.0.1';
const port = 3000;

const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Hello World');
});

server.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname}:${port}/`);
});*/

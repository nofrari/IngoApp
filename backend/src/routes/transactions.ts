import express from 'express';
import { PrismaClient, Transaction } from '@prisma/client';
import { z } from 'zod';
import multer from 'multer';
import PDFDocument, { options } from 'pdfkit';
const fs = require('fs');
import jwt from 'jsonwebtoken';
import verifyToken from '../middleware/verifyToken';
import bcrypt from 'bcrypt';
import { request } from 'http';
import path, { parse } from 'path';

const prisma = new PrismaClient();
const router = express.Router();
const parentDir = path.dirname(__dirname);

var storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, parentDir + '/uploads');
    console.log(parentDir);
    //cb(null, __dirname);
  },
  filename: function (req, file, cb) {
    cb(null, file.originalname);
  },
});

const upload = multer({ storage: storage });

const inputSchema = z.object({
  transaction_id: z.string().optional(),
  transaction_name: z.string(),
  transaction_amount: z.number(),
  date: z.string(),
  description: z.string().optional(),
  bill_url: z.string().optional(),
  category_id: z.string(),
  type_id: z.string(),
  interval_id: z.string(),
  interval_subtype_id: z.string().optional(),
  account_id: z.string(),
  transfer_account_id: z.string().optional()
});
type InputSchema = z.infer<typeof inputSchema>;

const editSchema = z.object({
  transaction_id: z.string().optional(),
  transaction_name: z.string().optional(),
  transaction_amount: z.number().optional(),
  date: z.string().optional(),
  description: z.string().optional(),
  bill_url: z.string().optional(),
  category_id: z.string().optional(),
  type_id: z.string().optional(),
  interval_id: z.string().optional(),
  interval_subtype_id: z.string().optional(),
  account_id: z.string().optional(),
  transfer_account_id: z.string().optional()
});
type EditSchema = z.infer<typeof editSchema>;

const changeAccountSchema = z.object({
  old_account_id: z.string(),
  new_account_id: z.string(),
});
type changeAccountSchema = z.infer<typeof changeAccountSchema>;

router.post('/transactions', (req, res) => {
  res.status(201).send('Hello world2');
});

router.get('/transactions/fetchpdf/:pdfname', async (req, res) => {
  try {
    res.status(201).send({
      pdf: await fs.promises.readFile(
        './src/uploads/' + req.params.pdfname,
        { encoding: 'base64' }
      ),
    });
  } catch (error) {
    console.log(error);
    res.status(400).send("Error while fetching pdf");
  }
});

router.post('/transactions/input', async (req, res) => {
  const body = <InputSchema>req.body;
  const validationResult: any = inputSchema.safeParse(body);

  if (!validationResult.success) {
    res.status(400).send();
    return;
  }

  //check if transaction is new or is updated
  const oldTransaction = await prisma.transaction.findUnique({
    where: {
      transaction_id: body.transaction_id,
    },
  });

  var updatedTransaction: Transaction | undefined;
  var newTransaction: Transaction | undefined;

  if (oldTransaction) {
    updatedTransaction = await prisma.transaction.update({
      where: {
        transaction_id: body.transaction_id,
      },
      data: {
        transaction_name: body.transaction_name,
        transaction_amount: body.transaction_amount,
        date: new Date(body.date),
        description: body.description,
        bill_url: body.bill_url,
        category_id: body.category_id,
        type_id: body.type_id,
        interval_id: body.interval_id,
        interval_subtype_id: body.interval_subtype_id == "" ? null : body.interval_subtype_id,
        account_id: body.account_id,
        transfer_account_id: body.transfer_account_id == "" ? null : body.transfer_account_id,

      },
    });

    if (!updatedTransaction) {
      res.status(400).send();
      return;
    }
  } else {

    newTransaction = await prisma.transaction.create({
      data: {
        transaction_name: body.transaction_name,
        transaction_amount: body.transaction_amount,
        date: new Date(body.date),
        description: body.description,
        bill_url: body.bill_url,
        category_id: body.category_id,
        type_id: body.type_id,
        interval_id: body.interval_id,
        interval_subtype_id: body.interval_subtype_id == "" ? null : body.interval_subtype_id,
        account_id: body.account_id,
        transfer_account_id: body.transfer_account_id == "" ? null : body.transfer_account_id,
      },
    });
  }


  if (!newTransaction && !updatedTransaction) {
    res.status(400).send();
    return;
  }

  const type = await prisma.type.findUnique({
    where: {
      type_id: body.type_id,
    },
  });

  switch (type?.type_name) {
    case 'Einnahme':
      await prisma.account.update({
        where: {
          account_id: body.account_id,
        },
        data: {
          account_balance: {
            increment: oldTransaction ? body.transaction_amount - oldTransaction.transaction_amount : body.transaction_amount,
          },
        },
      });
      break;
    case 'Ausgabe':
      await prisma.account.update({
        where: {
          account_id: body.account_id,
        },
        data: {
          account_balance: {
            decrement: oldTransaction ? body.transaction_amount - oldTransaction.transaction_amount : body.transaction_amount,
          },
        },
      });
      break;
    case 'Transfer':
      await prisma.account.updateMany({
        where: {
          account_id: body.account_id
        },
        data: {
          account_balance: {
            decrement: body.transaction_amount
          },
        },
      });



      await prisma.account.updateMany({
        where: {
          account_id: body.transfer_account_id
        },
        data: {
          account_balance: {
            increment: body.transaction_amount
          },
        },
      });
      break;
  }


  // const token = jwt.sign({
  //     userId: user.user_id,
  //     exp: Math.floor(Date.now() / 1000) + (60 * 60)
  // }, <string>process.env.JWT_SECRET);

  res.send({
    transaction_id: (oldTransaction ? updatedTransaction! : newTransaction!).transaction_id,
    transaction_name: (oldTransaction ? updatedTransaction! : newTransaction!).transaction_name,
    transaction_amount: (oldTransaction ? updatedTransaction! : newTransaction!).transaction_amount,
    date: (oldTransaction ? updatedTransaction! : newTransaction!).date,
    description: (oldTransaction ? updatedTransaction! : newTransaction!).description,
    bill_url: (oldTransaction ? updatedTransaction! : newTransaction!).bill_url,
    category_id: (oldTransaction ? updatedTransaction! : newTransaction!).category_id,
    type_id: (oldTransaction ? updatedTransaction! : newTransaction!).type_id,
    interval_id: (oldTransaction ? updatedTransaction! : newTransaction!).interval_id,
    interval_subtype_id: (oldTransaction ? updatedTransaction! : newTransaction!).interval_subtype_id,
    account_id: (oldTransaction ? updatedTransaction! : newTransaction!).account_id,
    transfer_account_id: (oldTransaction ? updatedTransaction! : newTransaction!).transfer_account_id,
  });
});

router.post('/transactions/edit', async (req, res) => {
  const body = <EditSchema>req.body;
  const validationResult: any = editSchema.safeParse(body);

  if (!validationResult.success) {
    res.status(400).send();
    return;
  }

  const transaction = await prisma.transaction.findUnique({
    where: {
      transaction_id: body.transaction_id,
    },
  });

  if (!transaction) {
    res.status(404).send();
    return;
  }

  const parsedDate = new Date(body.date!);

  try {
    await prisma.transaction.update({
      where: {
        transaction_id: body.transaction_id,
      },
      data: {
        transaction_name: body.transaction_name,
        transaction_amount: body.transaction_amount,
        date: parsedDate,
        description: body.description,
        bill_url: body.bill_url,
        category_id: body.category_id,
        type_id: body.type_id,
        interval_id: body.interval_id,
        interval_subtype_id: body.interval_subtype_id,
        account_id: body.account_id,
        transfer_account_id: body.transfer_account_id
      },
    });

    res.status(200).send();
  } catch (e) {
    console.log(e);
    res.status(404).send(e);
    return;
  }
});

router.post(
  '/transactions/pdfUpload',
  upload.single('pdf'),
  async (req, res) => {
    if (!req.file) {
      return res.status(422).send('At least one image is required');
    }

    res.send('PDF erfolgreich hochgeladen und gespeichert');
  }
);

router.delete('/transactions/:filename', (req, res) => {
  const filePath = parentDir + '/uploads/' + req.params.filename;
  console.log('FILEPFAD:' + filePath.toString());

  fs.unlink(filePath, (err: any) => {
    if (err) {
      console.error(err);
      res.status(500).send('Error deleting file');
    } else {
      console.log(`PDF file ${req.params.filename} deleted successfully`);
      res.send('PDF file deleted successfully');
    }
  });
});

router.delete('/transactions/delete/:id', async (req, res) => {
  const transaction = await prisma.transaction.delete({
    where: {
      transaction_id: req.params.id,
    },
  });

  if (!transaction) {
    return res.status(404).json({ message: 'Transaction nicht gefunden' });
  }

  const type = await prisma.type.findUnique({
    where: {
      type_id: transaction.type_id,
    },
  });

  switch (type?.type_name) {
    case 'Einnahme':
      await prisma.account.update({
        where: {
          account_id: transaction.account_id,
        },
        data: {
          account_balance: {
            decrement: transaction.transaction_amount,
          },
        },
      });
      break;
    case 'Ausgabe':
      await prisma.account.update({
        where: {
          account_id: transaction.account_id,
        },
        data: {
          account_balance: {
            increment: transaction.transaction_amount,
          },
        },
      });
      break;
    case 'Transfer':
      //TODO: Add transfer code
      await prisma.account.updateMany({
        where: {
          account_id: transaction.account_id
        },
        data: {
          account_balance: {
            increment: transaction.transaction_amount
          },
        },
      });



      await prisma.account.updateMany({
        where: {
          account_id: transaction.transfer_account_id as string
        },
        data: {
          account_balance: {
            decrement: transaction.transaction_amount
          },
        },
      });
      break;
  }

  res.json({ message: 'Transaction erfolgreich gelöscht' });
});

// router.get('/transactions', async (req, res) => {
//     const transactions = await prisma.transaction.findMany();
//     res.send(transactions);
// });

router.get('/transactions/:id', async (req, res) => {
  const id = req.params.id;

  const transaction = await prisma.transaction.findUnique({
    where: { transaction_id: id },
  });
  res.send(transaction);
});

router.get('/transactions/list/:user_id', async (req, res) => {
  const user_id = req.params.user_id;

  const transactions = await prisma.transaction.findMany({
    where: {
      category: {
        user: {
          user_id: user_id,
        },
      },
    },
    orderBy: { date: 'desc' },
  });

  //add all transactions from newTransactions to transactions
  transactions.push(...getRecurringTransactions(transactions));

  var duplicatedTransactions: Transaction[] = [];

  if (transactions.length !== 0) {
    for (let i = 0; i < transactions.length; i++) {
      const transaction = transactions[i];
      if (transaction.type_id === "3") {

        var duplicateTransaction = JSON.parse(JSON.stringify(transaction));


        var tempAccountId = duplicateTransaction.account_id;
        duplicateTransaction.account_id = duplicateTransaction.transfer_account_id;
        duplicateTransaction.transfer_account_id = tempAccountId;
        // transaction.type_id = "2";
        // duplicateTransaction.type_id = "1";
        transaction.transaction_amount = -transaction.transaction_amount;

        duplicatedTransactions.push(duplicateTransaction);
      }

    }

  }

  duplicatedTransactions.sort((a, b) => {
    const dateA = new Date(a.date);
    const dateB = new Date(b.date);
    return dateB.getTime() - dateA.getTime();
  });

  transactions.push(...duplicatedTransactions);

  //sort new transactions by date descending
  transactions.sort((a, b) => {
    return b.date.getTime() - a.date.getTime();
  }
  );
  console.log("---------------------------------------------------------------");
  res.send(transactions);
}
);

function getRecurringTransactions(transactions: Transaction[]) {
  var newTransactions: Transaction[] = [];
  const now = Date.now();
  const now2 = new Date();
  /*
  1 Nie
  2 Wöchentlich
  3 Monatlich
  4 Quartalsweise
  5 Halbjährlich
  6 Jährlich
  */

  /* 
  Subtypes
  1 Tag
  2 Wochentag
  */


  console.log(transactions.length, "transactions length");
  for (let i = 0; i < transactions.length; i++) {
    console.log(transactions.length, "for loop started");
    const transaction = transactions[i];
    switch (transaction.interval_id) {
      case "1":
        break;
      case "2":
        //goes through all dates that occured since the first transaction and adds the transaction to newTransactions
        var date: Date = new Date(JSON.parse(JSON.stringify(transaction.date)));
        date.setDate(date.getDate() + 7);
        while (date.getTime() < now) {
          newTransactions.push(getNewTransaction(transaction, date));
          date.setDate(date.getDate() + 7);
        }
        break;
      case "3":
        if (transaction.interval_subtype_id == "1") {
          var date: Date = new Date(JSON.parse(JSON.stringify(transaction.date)));
          while (date.getTime() < now) {
            newTransactions.push(getNewTransaction(transaction, date));
            //increase date by one months
            date.setMonth(date.getMonth() + 1);
          }
          break;

        } else if (transaction.interval_subtype_id == "2") {
          function getWeekOfMonth(date: Date): number {
            const firstDayOfMonth = new Date(date.getFullYear(), date.getMonth(), 1);
            const dayOfWeek = firstDayOfMonth.getDay();
            const adjustedDate = date.getDate() + dayOfWeek - 1;
            return Math.ceil(adjustedDate / 7);
          }

          var date: Date = new Date(JSON.parse(JSON.stringify(transaction.date)));
          date.setMonth(date.getMonth() + 1);
          date.setDate(1); // Setze den Tag auf den 1. des Monats

          // Wochentag im Bezug auf das Monat
          var targetDay = transaction.date.getDay();

          // Gewünschtes Wochentag-Vorkommen im Monat
          var targetWeek = getWeekOfMonth(transaction.date);

          // Finde das gewünschte Wochentag-Vorkommen im Monat
          var dayCount = 0;
          //so ganz macht das glaub ich keinen sinn, aber solangs funktioniert passts
          while (date.getTime() < now) {
            while (date.getMonth() <= now2.getMonth() && date.getFullYear() <= now2.getFullYear()) {
              if (date.getDay() === targetDay) {
                dayCount++;
                if (dayCount === targetWeek) { // Gewünschtes Vorkommen des Wochentags gefunden
                  newTransactions.push(getNewTransaction(transaction, date));
                  break; // Beende die Schleife nach Hinzufügen der Transaktion
                }
              }
              date.setDate(date.getDate() + 1); // Erhöhe das Datum um einen Tag
            }
            // Inkrementiere das Datum um einen Monat
            date.setMonth(date.getMonth() + 1);
            date.setDate(1); // Setze den Tag auf den 1. des Monats
            dayCount = 0; // Setze den Zähler für das Wochentag-Vorkommen zurück
          }
        }
        break;
      case "4":
        var date: Date = new Date(JSON.parse(JSON.stringify(transaction.date)));
        date.setMonth(date.getMonth() + 3);
        while (date.getTime() < now) {
          newTransactions.push(getNewTransaction(transaction, date));
          //increase date by three months
          date.setMonth(date.getMonth() + 3);
        }
        break;
      case "5":
        var date: Date = new Date(JSON.parse(JSON.stringify(transaction.date)));
        date.setMonth(date.getMonth() + 6);
        while (date.getTime() < now) {
          newTransactions.push(getNewTransaction(transaction, date));
          //increase date by six months
          date.setMonth(date.getMonth() + 6);
        }
        break;
      case "6":
        var date: Date = new Date(JSON.parse(JSON.stringify(transaction.date)));
        date.setFullYear(date.getFullYear() + 1);
        while (date.getTime() < now) {
          newTransactions.push(getNewTransaction(transaction, date));
          //increase date by one year
          date.setFullYear(date.getFullYear() + 1);
        }
        break;
    }
  }

  return newTransactions;

  //remove first transactions from newTransactions, because its the same is the first transaction in transactions
  //newTransactions.shift();
}

function getNewTransaction(transaction: Transaction, date: Date) {
  console.log("date", date);
  var newTransaction = JSON.parse(JSON.stringify(transaction));
  var newDate = date;
  newTransaction.date = newDate;
  var deepTransaction: Transaction = JSON.parse(JSON.stringify(newTransaction));
  deepTransaction.date = new Date(JSON.parse(JSON.stringify(newDate)));
  return deepTransaction;
}

// function getWeekdayCount(date: Date) {
//   const firstDayOfMonth = new Date(date.getFullYear(), date.getMonth(), 1);
//   const weekday = firstDayOfMonth.getDay();
//   const currentWeekday = date.getDay();

//   const weeks = ((date.get - weekday) / 7).floor();
//   int extraDays = (now.day - weekday) % 7;

//   if (currentWeekday < weekday) {
//     return weeks + 1;
//   } else if (currentWeekday >= weekday && extraDays >= currentWeekday) {
//     return weeks + 2;
//   } else {
//     return weeks + 1;
//   }
// }

router.get('/transactions/fivelatest/:user_id', async (req, res) => {
  const user_id = req.params.user_id;

  const transactions = await prisma.transaction.findMany({
    where: {
      category: {
        user: {
          user_id: user_id,
        },
      },
    },
    orderBy: { date: 'desc' },
    take: 5,
  });

  res.send(transactions);
});

router.get('/transactions/account/:id', async (req, res) => {
  console.log('called');
  const id = req.params.id;

  const transaction = await prisma.transaction.findMany({
    where: {
      account_id: id,
    },
  });
  res.send(transaction);
});

router.post('/transactions/change', async (req, res) => {
  const body = <changeAccountSchema>req.body;
  const validationResult: any = changeAccountSchema.safeParse(body);

  if (!validationResult.success) {
    res.status(400).send();
    return;
  }

  //First get sum of old account
  const oldAccount = await prisma.account.findUnique({
    where: {
      account_id: body.old_account_id,
    },
  });

  //First get sum of old account
  const newAccount = await prisma.account.findUnique({
    where: {
      account_id: body.new_account_id,
    },
  });

  const newAmount: number =
    (oldAccount ? oldAccount.account_balance : 0) +
    (newAccount ? newAccount.account_balance : 0);

  //update amount
  try {
    await prisma.account.update({
      where: {
        account_id: body.new_account_id,
      },
      data: {
        account_balance: newAmount,
      },
    });
    res.status(200).send();
  } catch (e) {
    console.log(e);
    res.status(404).send(e);
    return;
  }

  //update transactions
  try {
    await prisma.transaction.updateMany({
      where: {
        account_id: body.old_account_id,
      },
      data: {
        account_id: body.new_account_id,
      },
    });

    res.status(200).send();
  } catch (e) {
    console.log(e);
    res.status(404).send(e);
    return;
  }
});

export default router;

import express from 'express';
import { PrismaClient } from '@prisma/client';
import { z } from 'zod';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import nodemailer from 'nodemailer';
const process = require('process');

const prisma = new PrismaClient();
const router = express.Router();
//is used to check the parameters of the request body
const registerSchema = z.object({
    user_name: z.string(),
    user_sirname: z.string(),
    email: z.string(),
    password: z.string(),
    email_confirmed: z.boolean().optional(),
});
type RegisterSchema = z.infer<typeof registerSchema>;

const loginSchema = z.object({
    email: z.string(),
    password: z.string()
});
type LoginSchema = z.infer<typeof loginSchema>;

const editSchema = z.object({
    user_id: z.string(),
    user_name: z.string().optional(),
    user_sirname: z.string().optional(),
    email: z.string(),
    old_password: z.string().optional(),
    new_password: z.string().optional(),
});
type EditSchema = z.infer<typeof editSchema>;

const resetPasswordSchema = z.object({
    email: z.string(),
});
type ResetPasswordSchema = z.infer<typeof resetPasswordSchema>;

// const confirmEmailSchema = z.object({
//     email: z.string(),
//     email_confirmed: z.boolean()
// });
// type ConfirmEmailSchema = z.infer<typeof confirmEmailSchema>;

const transporter = nodemailer.createTransport({
    host: 'smtp.world4you.com',
    port: 587,
    secure: false,
    auth: {
      user: 'office@ingoapp.at',
      pass: 'IagnryNX!26_4go',
    },
  });

//edit user
router.post('/users/edit', async (req, res) => {
    const body = <EditSchema>req.body;
    const validationResult = editSchema.safeParse(body);

    if (!validationResult.success) {
        res.status(400).send();
        return;
    }

    const user = await prisma.user.findUnique({
        where: {
            user_id: body.user_id
        }
    });

    if (!user) {
        res.status(404).send();
        return;
    }

    //if blocks to check which parameter is sent in the request body and then update the database
    if (body.user_name && body.user_sirname && body.email) {
        await prisma.user.update({
            where: {
                user_id: body.user_id
            },
            data: {
                user_name: body.user_name,
                user_sirname: body.user_sirname,
                email: body.email
            }
        });

        res.status(200).send();

    } else if (body.old_password && body.new_password) {
        const match = await bcrypt.compare(body.old_password, user.password);

        if (!match) {
            res.status(401).send();
            return;
        }

        const hash = await bcrypt.hash(body.new_password, 10);

        await prisma.user.update({
            where: {
                user_id: body.user_id
            },
            data: {
                password: hash
            }
        });

        res.status(200).send();

    } else {
        res.status(406).send();
        return;
    }
});

//create new user (register)
router.post('/users/register', async (req, res) => {
    const body = <RegisterSchema>req.body;
    const validationResult = registerSchema.safeParse(body);

    if (!validationResult.success) {
        res.status(400).send();
        return;
    }

    const existingUser = await prisma.user.findUnique({
        where: {
            email: body.email
        }
    });

    if (existingUser) {
        res.status(409).send();
        console.log(existingUser);
        return;
    }

    const hash = await bcrypt.hash(body.password, 10);

    const user = await prisma.user.create({
      data: {
        user_name: body.user_name,
        user_sirname: body.user_sirname,
        email: body.email,
        password: hash,
        email_confirmed: false,
      }
    });

    //create confirmation token and send email
    const confirmationToken = jwt.sign({
     //token expires after 10 minutes
     userId: user.user_id,
      exp: Math.floor(Date.now() / 1000) + (60 * 10)
    }, process.env.JWT_SECRET);

    sendConfirmationEmail(user.email, confirmationToken);   
 
    res.status(200).send({
    message: 'Registration successful. Please check your email for confirmation.',
    user_id: user.user_id,
        user_name: user.user_name,
        user_sirname: user.user_sirname,
        email: user.email
    });
});

//get one user by id
//for testing: copy token from login or register and paste it in the authorization header under Bearer token
router.get('/users/:id', async (req, res) => {
    const user = await prisma.user.findUnique({ where: { user_id: req.params.id } });
    res.send(user);
});

router.get('/users/delete/:id', async (req, res) => {
    try {
        await prisma.user.delete({ where: { user_id: req.params.id } });
        res.send(200);
    } catch (error) {
        res.send(error);
    }});

//confirm email
router.get('/users/confirm-email/:confirmationToken', async (req, res) => {
   try {
    //decode token
    var decodedToken = await <any>jwt.decode(req.params.confirmationToken, process.env.JWT_SECRET);
    console.log('decodedToken', decodedToken);

    // Retrieve the user from the database
    var user = await prisma.user.findUnique({
      where: {
        user_id: decodedToken.userId,
      },
    }); 
    console.log('user', user);

    if (!user) {
      res.redirect('https://www.ingoapp.at/kein-user');
      res.status(400).send('Could not find user');
      return;
    }

    if (!user.email_confirmed) {
      await jwt.verify(req.params.confirmationToken, process.env.JWT_SECRET);

      // Update the user's email_confirmed property to true
      const updatedUser = await prisma.user.update({
        where: {
          user_id: decodedToken.userId,
        },
        data: {
          email_confirmed: true,
        },
      });
      console.log('updatedUser', updatedUser);
      
      res.redirect('https://www.ingoapp.at/email-bestaetigt');
    } else {
      res.redirect('https://www.ingoapp.at/email-bestaetigt');
      return;
    }

    } catch (error) {  
      console.log('wir sind im catch');
      // Retrieve the user from the database
      var user = await prisma.user.findUnique({
        where: {
          user_id: decodedToken.userId,
        },
      }); 
      //if there is no user with the provided id
      if (user) {
        await prisma.user.delete({ where: { user_id: decodedToken.userId } });
        res.redirect('https://www.ingoapp.at/token-abgelaufen');
        return;
      } else {
        return;
      }   
    }
  });

  //user login
  router.post('/users/login', async (req, res) => {
    const body = <LoginSchema>req.body;
    const validationResult = loginSchema.safeParse(body);

    if (!validationResult.success) {
        res.status(400).send();
        return;
    }

    const user = await prisma.user.findUnique({
        where: {
            email: body.email
        }
    });

    if (!user) {
        res.status(404).send();
        return;
    }

    const match = await bcrypt.compare(body.password, user.password);

    if (!match) {
        res.status(401).send();
        return;
    }

    const confirmed = user.email_confirmed;

    if (!confirmed) { 
        res.status(403).send();
        return; 
    }

    //check how many accounts the user has
    const accounts = await prisma.account.findMany({
        where: {
            user_id: user.user_id
        }
    });

    res.status(200).send({
        //accessToken: token,
        user_id: user.user_id,
        user_name: user.user_name,
        user_sirname: user.user_sirname,
        email: user.email,
        pin: user.pin,
        number_accounts: accounts.length
    });
  })

  // Reset password / send mail
  router.post('/users/reset-password', async (req, res) => {
    const body = <ResetPasswordSchema>req.body;
    const validationResult = resetPasswordSchema.safeParse(body);

    if (!validationResult.success) {
        res.status(400).send();
        return;
    }
  
    // Check if the user with the provided email exists
    const user = await prisma.user.findUnique({
      where: {
        email: body.email,
      },
    });
  
    if (!user) {
      res.status(404).send();
      return;
    }
  
    // Generate a new password
    const newPassword = generateNewPassword(); // Implement your logic to generate a new password
  
    // Update the user's password in the database
    const hash = await bcrypt.hash(newPassword, 10);
    await prisma.user.update({
      where: {
        email: body.email,
      },
      data: {
        password: hash,
      },
    });
  
    // Send the new password to the user's email
    sendPasswordResetEmail(body.email, newPassword); // Implement your logic to send the email
  
    res.status(200).send("Password reset successfully");
  });

  router.post('/users/init', async (req, res) => {
    try {
        // Hier kannst du deine vordefinierten Werte angeben
        const predefinedInterval = [
            { interval_name: 'Nie' },
            { interval_name: 'Wöchentlich' },
            { interval_name: 'Monatlich' },
            { interval_name: 'Vierteljährlich' },
            { interval_name: 'Halbjährlich' },
            { interval_name: 'Jährlich' },
        ];

        const predefinedTypes = [
            { type_name: 'Einnahmen' },
            { type_name: 'Ausgaben' },
            { type_name: 'Transaktion' },
        ];

        // Hier kannst du den Code zum Speichern der Werte in die Datenbank einfügen
        await prisma.interval.createMany({
            data: predefinedInterval,
        });

        await prisma.type.createMany({
            data: predefinedTypes,
        });

        res.status(200).json({ message: 'Vordefinierte Werte erfolgreich in die Datenbank geschrieben.' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Interner Serverfehler.' });
    }
  });

  router.get('/types', async (req, res) => {
      const types = await prisma.type.findMany();
      res.send(types);
  });

  router.get('/intervals', async (req, res) => {

      const intervals = await prisma.interval.findMany();
      res.send(intervals);
  });

  router.get('/intervalsubtypes', async (req, res) => {

      const intervalsubtypes = await prisma.intervalSubtype.findMany();
      res.send(intervalsubtypes);
  });

  // --------------------------- Functions ---------------------------
  
  // Email confirmation
  function sendConfirmationEmail(email: any, confirmationToken: string | number) {
    const confirmationLink = `https://data.ingoapp.at/users/confirm-email/${confirmationToken}`; 
    //`https://157.90.249.232:5432/users/confirm-email/${confirmationToken}`;
  
    const mailOptions = {
      from: 'office@ingoapp.at',
      to: email, 
      subject: 'Email bestätigen',
      text: `Hi! \n\nDanke für deine Registrierung! Als letzten Schritt klicke bitte auf folgenden Link, um deine Email zu bestätigen: ${confirmationLink}\n\nDieser Link ist für 10 Minuten gültig. \n\nSolltest du dich nicht registriert haben, ignoriere diese Email bitte.`
    };
  
    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.error('Error sending email:', error);
      } else {
        console.log('Email sent:', info.response);
      }
    });}

   
  // Password reset
  function generateNewPassword() {
    const length = 10; // Length of the new password
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'; // Characters to include in the new password
    let newPassword = '';
  
    for (let i = 0; i < length; i++) {
      const randomIndex = Math.floor(Math.random() * characters.length);
      newPassword += characters[randomIndex];
    }
  
    return newPassword;
  }
  
  function sendPasswordResetEmail(email: any, newPassword: string) {
    const mailOptions = {
      from: 'office@ingoapp.at',
      to: email, 
      subject: 'Passwort erfolgreich zurückgesetzt',
      text: `Hi! \n Du hast erfolgreich dein Passwort zurückgesetzt. Dein neues Passwort lautet ${newPassword}. \n Du kannst dieses Passwort jederzeit in deinen Profileinstellungen wieder ändern`,
    };
  
    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.error('Error sending email:', error);
      } else {
        console.log('Email sent:', info.response);
      }
    });
  }

export default router;


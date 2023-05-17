import express from 'express';
import { PrismaClient } from '@prisma/client';
import { z } from 'zod';
import jwt from 'jsonwebtoken';
import verifyToken from '../middleware/verifyToken';
import bcrypt from 'bcrypt';
import nodemailer from 'nodemailer';

const prisma = new PrismaClient();
const router = express.Router();
//is used to check the parameters of the request body
const registerSchema = z.object({
    user_name: z.string(),
    user_sirname: z.string(),
    email: z.string(),
    password: z.string()
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
    if (body.user_name) {
        await prisma.user.update({
            where: {
                user_id: body.user_id
            },
            data: {
                user_name: body.user_name
            }
        });

        res.status(200).send();

    } else if (body.user_sirname) {
        await prisma.user.update({
            where: {
                user_id: body.user_id
            },
            data: {
                user_sirname: body.user_sirname
            }
        });

        res.status(200).send();

    } else if (body.email) {
        await prisma.user.update({
            where: {
                user_id: body.user_id
            },
            data: {
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
            password: hash
        }
    });

    const token = jwt.sign({
        userId: user.user_id,
        exp: Math.floor(Date.now() / 1000) + (60 * 60)
    }, <string>process.env.JWT_SECRET);

    res.send({
        accessToken: token,
        user_id: user.user_id,
        username: user.user_name,
        user_sirname: user.user_sirname,
        email: user.email
    });
});

//Get all users, not really needed in our case
// router.get('/users', async (req, res) => {
//     const users = await prisma.user.findMany();
//     res.send(users);
// });

//get one user by id
//for testing: copy token from login or register and paste it in the authorization header under Bearer token
router.get('/users/:id', verifyToken, async (req, res) => {
    if (res.locals.user.userId !== req.params.id) {
        res.status(403).send();
    }
    const user = await prisma.user.findUnique({ where: { user_id: req.params.id } });
    res.send(user);
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

    const token = jwt.sign({
        userId: user.user_id,
        exp: Math.floor(Date.now() / 1000) + (60 * 60 * 24 * 30)
    }, <string>process.env.JWT_SECRET);

    res.status(200).send({
        accessToken: token,
        user_id: user.user_id,
        username: user.user_name,
        user_sirname: user.user_sirname,
        email: user.email,
        pin: user.pin
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
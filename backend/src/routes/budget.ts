import express from 'express';
import { PrismaClient, Budget } from '@prisma/client';
import { z } from 'zod';

const prisma = new PrismaClient();
const router = express.Router();

const inputSchema = z.object({
  budget_id: z.string().optional(),
  budget_name: z.string(),
  budget_amount: z.number(),
  startdate: z.string(),
  enddate: z.string(),
  user_id: z.string(),
  category_ids: z.array(z.string()),
});
type InputSchema = z.infer<typeof inputSchema>;

const editSchema = z.object({
  budget_id: z.string().optional(),
  budget_name: z.string(),
  budget_amount: z.number(),
  startdate: z.string(),
  enddate: z.string(),
  user_id: z.string(),
  category_ids: z.array(z.string()),
});
type EditSchema = z.infer<typeof editSchema>;

router.post('/budget/input', async (req, res) => {
  const body = <InputSchema>req.body;
  const validationResult: any = inputSchema.safeParse(body);

  if (!validationResult.success) {
    res.status(400).send();
    return;
  }

  //check if budget is new or is updated
  const oldBuget = await prisma.budget.findUnique({
    where: {
      budget_id: body.budget_id,
    },
  });

  var updatedBudget: Budget | undefined;
  var newBudget: Budget | undefined;

  if (oldBuget) {
    updatedBudget = await prisma.budget.update({
      where: {
        budget_id: body.budget_id,
      },
      data: {
        budget_name: body.budget_name,
        budget_amount: body.budget_amount,
        startdate: new Date(body.startdate),
        enddate: new Date(body.startdate),
        categories: {
          connect: body.category_ids.map((categoryId) => ({
            category_id: categoryId,
          })),
        },
      },
    });

    if (!updatedBudget) {
      res.status(400).send();
      return;
    }
  } else {
    const newBudget = await prisma.budget.create({
      data: {
        budget_name: body.budget_name,
        budget_amount: body.budget_amount,
        startdate: new Date(body.startdate),
        enddate: new Date(body.enddate),
        user: { connect: { user_id: body.user_id } }, // Verknüpfung mit dem entsprechenden Benutzer
        categories: {
          connect: body.category_ids.map((categoryId) => ({
            category_id: categoryId,
          })),
        }, // Verknüpfung mit den ausgewählten Kategorie-IDs
      },
    });
  }

  if (!newBudget && !updatedBudget) {
    res.status(400).send();
    return;
  }
  // res.send({
  //   budget_id: (oldBuget ? updatedBudget! : newBudget!).budget_id,
  //   budget_name: (oldBuget ? updatedBudget! : newBudget!).budget_name,
  //   budget_amount: (oldBuget ? updatedBudget! : newBudget!).budget_amount,
  //   startdate: (oldBuget ? updatedBudget! : newBudget!).startdate,
  //   enddate: (oldBuget ? updatedBudget! : newBudget!).enddate,
  // });
  res.send(oldBuget ? updatedBudget : newBudget);
});

//Get one budget
router.get('/budget/:id', async (req, res) => {
  const id = req.params.id;

  const budget = await prisma.budget.findUnique({
    where: { budget_id: id },
    include: {
      categories: true,
    },
  });
  res.send(budget);
});

//Get all budgets of user
router.get('/budget/list/:user_id', async (req, res) => {
  const user_id = req.params.user_id;

  const budgets = await prisma.budget.findMany({
    where: {
      user_id: user_id,
    },
    orderBy: { startdate: 'desc', enddate: 'desc' },
    include: {
      categories: true,
    },
  });
  res.send(budgets);
});

//Delete a budget
router.delete('/budget/delete/:id', async (req, res) => {
  const budget = await prisma.budget.delete({
    where: {
      budget_id: req.params.id,
    },
  });

  if (!budget) {
    return res.status(404).json({ message: 'Budget nicht gefunden' });
  }
  res.json({ message: 'Transaction erfolgreich gelöscht' });
});

export default router;

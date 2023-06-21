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

  // //check if budget is new or is updated
  const oldBuget = await prisma.budget.findUnique({
    where: {
      budget_id: body.budget_id,
    },
  });

  var updatedBudget: Budget | undefined;
  var newBudget: Budget | undefined;

  const parsedStartDate = new Date(body.startdate.replace(' ', 'T'));
  const parsedEndDate = new Date(body.enddate.replace(' ', 'T'));

  const localStartDate = new Date(
    parsedStartDate.getTime() - parsedStartDate.getTimezoneOffset() * 60000
  );
  const localEndDate = new Date(
    parsedEndDate.getTime() - parsedEndDate.getTimezoneOffset() * 60000
  );

  if (oldBuget) {
    updatedBudget = await prisma.budget.update({
      where: {
        budget_id: body.budget_id,
      },
      data: {
        budget_name: body.budget_name,
        budget_amount: body.budget_amount,
        startdate: localStartDate,
        enddate: localEndDate,
        categories: {
          set: body.category_ids.map((category_id) => ({ category_id })),
        },
      },
    });

    if (!updatedBudget) {
      res.status(400).send();
      return;
    }
  } else {
    newBudget = await prisma.budget.create({
      data: {
        budget_name: body.budget_name,
        budget_amount: body.budget_amount,
        startdate: localStartDate,
        enddate: localEndDate,
        user: { connect: { user_id: body.user_id } },
        categories: {
          connect: body.category_ids.map((category_id) => ({ category_id })),
        }, // Verknüpfung mit dem entsprechenden Benutzer
      },
      include: {
        categories: true,
      },
    });
  }

  if (!newBudget && !updatedBudget) {
    res.status(400).send();
    return;
  }

  res.send(oldBuget ? { oldBuget } : { newBudget });
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
router.get('/budgets/list/:user_id', async (req, res) => {
  const user_id = req.params.user_id;

  const budgets = await prisma.budget.findMany({
    where: {
      user_id: user_id,
    },
    orderBy: { budget_name: 'asc' },
    include: {
      categories: true,
    },
  });
  res.send(budgets);
});

//Delete a budget
router.delete('/budgets/delete/:id', async (req, res) => {
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

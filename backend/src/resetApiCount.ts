import { PrismaClient, User } from '@prisma/client';

const prisma = new PrismaClient();

async function resetApiCount() {
    try {
        const counter = await prisma.apiCalls.findFirst();
        if (!counter) {
            throw new Error('No counter found');
        }
        const updatedCounter = await prisma.apiCalls.update({
            where: { api_calls_id: counter.api_calls_id },
            data: { count: 0 },
        });

        prisma.$disconnect();
    } catch (error) {
        console.error('Error checking unconfirmed users:', error);
    }
}

resetApiCount();
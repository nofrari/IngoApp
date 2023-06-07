import { PrismaClient, User } from '@prisma/client';

const prisma = new PrismaClient();

async function checkUnconfirmedUsers() {
    try {
        const tenMinutesAgo = new Date();
        tenMinutesAgo.setMinutes(tenMinutesAgo.getMinutes() - 10);

        const unconfirmedUsers = await prisma.user.findMany({
            where: {
                email_confirmed: false,
                created_at: {
                    lt: tenMinutesAgo,
                },
            },
        });

        unconfirmedUsers.forEach(async (user: User) => {
            console.log(`Found unconfirmed user: ${user.user_name}`);
            // Hier kannst du weitere Aktionen mit dem Benutzer durchführen
            await prisma.user.delete({ where: { user_id: user.user_id } });
        });

        prisma.$disconnect();
    } catch (error) {
        console.error('Error checking unconfirmed users:', error);
    }
}

checkUnconfirmedUsers();
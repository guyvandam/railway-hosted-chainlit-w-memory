-- AlterTable
ALTER TABLE "Element" ALTER COLUMN "metadata" SET DEFAULT '{}';

-- AlterTable
ALTER TABLE "Step" ALTER COLUMN "metadata" SET DEFAULT '{}';

-- AlterTable
ALTER TABLE "Thread" ALTER COLUMN "metadata" SET DEFAULT '{}',
ALTER COLUMN "tags" DROP DEFAULT;

-- AlterTable
ALTER TABLE "User" ALTER COLUMN "metadata" SET DEFAULT '{}';

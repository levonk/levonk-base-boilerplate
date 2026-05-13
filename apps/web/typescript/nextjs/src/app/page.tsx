import CachedTimestamp from '../components/CachedTimestamp';

export default function Page() {
  return (
    <main className="min-h-screen flex flex-col items-center justify-center p-8 gap-4">
      <h1 className="text-3xl font-semibold">Next.js 16 App Router Boilerplate</h1>
      <p className="text-gray-500">Barebones starter with essential configurations.</p>

      <div className="mt-8">
        <CachedTimestamp />
      </div>
    </main>
  );
}

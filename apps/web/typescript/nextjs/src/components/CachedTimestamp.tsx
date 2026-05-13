'use cache';

async function getTimestamp() {
  return new Date().toISOString();
}

export default async function CachedTimestamp() {
  const time = await getTimestamp();
  return (
    <div className="p-4 border rounded-lg bg-gray-50 dark:bg-gray-900">
      <h3 className="font-bold mb-2">Static Cached Component</h3>
      <p>This timestamp is cached at build time (or first render) and won't change on refresh:</p>
      <code className="block mt-2 p-2 bg-gray-200 dark:bg-gray-800 rounded">{time}</code>
      <p className="text-xs text-gray-500 mt-2">
        (Powered by the <code>"use cache"</code> directive)
      </p>
    </div>
  );
}

import { getCurrentUser } from "@/lib/auth/session";
import { redirect } from "next/navigation";

export default async function DashboardPage() {
  const user = await getCurrentUser();

  if (!user) {
    redirect("/sign-in");
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
            <div className="flex items-center space-x-4">
              <span className="text-sm text-gray-700">
                Welcome, {user.name || user.email}
              </span>
              <form action="/api/auth/sign-out" method="POST">
                <button
                  type="submit"
                  className="bg-red-600 hover:bg-red-700 text-white font-medium py-2 px-4 rounded-md text-sm"
                >
                  Sign Out
                </button>
              </form>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div className="px-4 py-6 sm:px-0">
          <div className="border-4 border-dashed border-gray-200 rounded-lg h-96 flex items-center justify-center">
            <div className="text-center">
              <h2 className="text-2xl font-semibold text-gray-900 mb-2">
                Welcome to your dashboard!
              </h2>
              <p className="text-gray-600 mb-4">
                You are successfully authenticated with Better-Auth.
              </p>
              <div className="bg-gray-100 p-4 rounded-lg text-left">
                <h3 className="font-medium text-gray-900 mb-2">User Information:</h3>
                <ul className="text-sm text-gray-600 space-y-1">
                  <li><strong>ID:</strong> {user.id}</li>
                  <li><strong>Email:</strong> {user.email}</li>
                  <li><strong>Name:</strong> {user.name || "Not set"}</li>
                  <li><strong>Email Verified:</strong> {user.emailVerified ? "Yes" : "No"}</li>
                  <li><strong>Role:</strong> {user.role}</li>
                  <li><strong>Created:</strong> {user.createdAt?.toLocaleString()}</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

import { authMiddleware } from "@/lib/auth/auth";

export default authMiddleware((req) => {
  // This is where you can define which routes should be protected
  // By default, all routes are protected when a user is not authenticated
  // You can customize this logic based on your needs
  if (req.nextUrl.pathname.startsWith("/api/auth")) {
    // Allow auth routes to pass through
    return;
  }
  
  if (req.nextUrl.pathname.startsWith("/_next")) {
    // Allow Next.js internal routes
    return;
  }
  
  if (req.nextUrl.pathname.startsWith("/static")) {
    // Allow static files
    return;
  }
});

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     */
    "/((?!api|_next/static|_next/image|favicon.ico).*)",
  ],
};

// vim: set ft=typescript:

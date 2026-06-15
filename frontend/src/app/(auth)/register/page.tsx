import { redirect } from "next/navigation";

export default function RegisterPage() {
  // We merged Login and Register into a single portal with Role Selection
  redirect("/login");
}

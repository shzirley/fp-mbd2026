"use client";

import { useState } from "react";
import Link from "next/link";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import Cookies from "js-cookie";
import { useRouter } from "next/navigation";
import { useGoogleLogin } from "@react-oauth/google";
export default function LoginPage() {
  const router = useRouter();
  const [role, setRole] = useState<"pelanggan" | "pegawai">("pelanggan");

  const loginGoogle = useGoogleLogin({
    onSuccess: async (tokenResponse) => {
      try {
        console.log("Mengirim token ke backend...");
        const res = await fetch("http://localhost:5000/api/auth/google", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ access_token: tokenResponse.access_token }),
        });
        
        const data = await res.json();
        if (res.ok) {
          console.log("Login Berhasil:", data);
          Cookies.set("cinetrack_token", data.token, { expires: 7 });
          Cookies.set("cinetrack_user", JSON.stringify(data.user), { expires: 7 });
          
          alert(`Berhasil login sebagai ${data.user.name}`);
          router.push("/pelanggan");
        } else {
          console.error("Login gagal:", data.message);
          alert("Gagal login: " + data.message);
        }
      } catch (err) {
        console.error("Terjadi kesalahan jaringan:", err);
      }
    },
    onError: (error) => console.log("Google Login Failed", error),
  });

  const loginPegawaiGoogle = useGoogleLogin({
    onSuccess: async (tokenResponse) => {
      try {
        console.log("Mengirim token pegawai ke backend...");
        const res = await fetch("http://localhost:5000/api/auth/pegawai/google", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ access_token: tokenResponse.access_token }),
        });
        
        const data = await res.json();
        if (res.ok) {
          console.log("Login Pegawai Berhasil:", data);
          Cookies.set("cinetrack_token", data.token, { expires: 7 });
          Cookies.set("cinetrack_user", JSON.stringify(data.user), { expires: 7 });
          
          alert(`Berhasil login sebagai Pegawai: ${data.user.name}`);
          router.push("/pegawai");
        } else {
          console.error("Login gagal:", data.message);
          alert("Gagal login: " + data.message);
        }
      } catch (err) {
        console.error("Terjadi kesalahan jaringan:", err);
      }
    },
    onError: (error) => console.log("Google Login Failed", error),
  });

  return (
    <div className="glass rounded-2xl p-8 sm:p-10 w-full shadow-2xl border border-brand-border/50">
      <div className="text-center mb-8">
        <h2 className="text-2xl font-bold text-white mb-2">Welcome to Cinetrack</h2>
        <p className="text-brand-text-muted text-sm">Please select your login role</p>
      </div>

      {/* Role Selection Tabs */}
      <div className="flex w-full mb-8 bg-brand-bg rounded-lg p-1 border border-brand-border">
        <button
          type="button"
          onClick={() => setRole("pelanggan")}
          className={`flex-1 py-2 text-sm font-medium rounded-md transition-all ${
            role === "pelanggan"
              ? "bg-brand-neon-pink text-white shadow-lg shadow-brand-neon-pink/20"
              : "text-brand-text-muted hover:text-white"
          }`}
        >
          Customer
        </button>
        <button
          type="button"
          onClick={() => setRole("pegawai")}
          className={`flex-1 py-2 text-sm font-medium rounded-md transition-all ${
            role === "pegawai"
              ? "bg-brand-neon-pink text-white shadow-lg shadow-brand-neon-pink/20"
              : "text-brand-text-muted hover:text-white"
          }`}
        >
          Employee
        </button>
      </div>

      {role === "pelanggan" ? (
        <div className="space-y-6">
          <div className="text-center text-sm text-brand-text-muted mb-6">
            <p>Customers can securely sign in using Google.</p>
            <p>No password required.</p>
          </div>
          
          <Button variant="google" fullWidth onClick={() => loginGoogle()}>
            <svg className="w-5 h-5" viewBox="0 0 24 24">
              <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4" />
              <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853" />
              <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05" />
              <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335" />
            </svg>
            Continue with Google
          </Button>

          <p className="mt-8 text-center text-sm text-brand-text-muted">
            New here?{" "}
            <button onClick={() => loginGoogle()} className="text-brand-neon-pink hover:text-brand-neon-pink-hover transition-colors font-medium">
              Create an account
            </button>
          </p>
        </div>
      ) : (
        <div className="space-y-6">
          <form className="space-y-5">
            <Input 
              label="Employee Email" 
              type="email" 
              placeholder="staff@cinetrack.com"
              icon={
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-5 h-5">
                  <path d="M3 4a2 2 0 00-2 2v8a2 2 0 002 2h14a2 2 0 002-2V6a2 2 0 00-2-2H3zm0 2h14v.511l-7 4.2-7-4.2V6zm14 8H3V8.8l6.486 3.891a1 1 0 001.028 0L17 8.8V14z" />
                </svg>
              }
            />

            <div>
              <div className="flex justify-between items-center mb-2">
                 <label className="block text-sm font-medium text-brand-text-muted">Password</label>
                 <Link href="#" className="text-xs text-brand-neon-pink hover:text-brand-neon-pink-hover transition-colors">
                   Forgot Password?
                 </Link>
              </div>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-brand-text-muted">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-5 h-5">
                    <path fillRule="evenodd" d="M10 1a4.5 4.5 0 00-4.5 4.5V9H5a2 2 0 00-2 2v6a2 2 0 002 2h10a2 2 0 002-2v-6a2 2 0 00-2-2h-.5V5.5A4.5 4.5 0 0010 1zm3 8V5.5a3 3 0 10-6 0V9h6z" clipRule="evenodd" />
                  </svg>
                </div>
                <input
                  type="password"
                  placeholder="••••••••"
                  className="w-full bg-brand-input border border-brand-border text-brand-text text-sm rounded-lg focus:ring-brand-neon-blue focus:border-brand-neon-blue block p-3 pl-10 pr-10 transition-colors"
                />
              </div>
            </div>

            <Button type="submit" fullWidth className="mt-6">
              Sign In to Dashboard <span className="ml-1">→</span>
            </Button>
          </form>

          <div className="mt-6 relative">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-brand-border"></div>
            </div>
            <div className="relative flex justify-center text-sm">
              <span className="px-2 bg-brand-card text-brand-text-muted text-xs uppercase tracking-wider glass">
                Or login with
              </span>
            </div>
          </div>

          <Button variant="google" fullWidth onClick={() => loginPegawaiGoogle()}>
            <svg className="w-5 h-5" viewBox="0 0 24 24">
              <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4" />
              <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853" />
              <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05" />
              <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335" />
            </svg>
            Sign in as Employee
          </Button>
        </div>
      )}
    </div>
  );
}

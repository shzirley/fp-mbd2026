"use client";

import { useEffect, useState } from "react";
import Cookies from "js-cookie";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/Button";

export default function PelangganDashboard() {
  const router = useRouter();
  const [user, setUser] = useState<any>(null);

  useEffect(() => {
    // Membaca user info dari cookies atau local storage
    const userInfo = Cookies.get("cinetrack_user");
    if (!userInfo) {
      router.push("/login");
      return;
    }
    
    try {
      const parsedUser = JSON.parse(userInfo);
      if (parsedUser.role !== "pelanggan") {
        router.push("/login");
        return;
      }
      setUser(parsedUser);
    } catch (e) {
      router.push("/login");
    }
  }, [router]);

  const handleLogout = () => {
    Cookies.remove("cinetrack_token");
    Cookies.remove("cinetrack_user");
    router.push("/");
  };

  if (!user) return <div className="min-h-screen bg-brand-bg flex items-center justify-center text-white">Loading...</div>;

  return (
    <div className="min-h-screen bg-brand-bg text-brand-text p-8">
      <div className="max-w-6xl mx-auto">
        <div className="flex justify-between items-center mb-10">
          <div>
            <h1 className="text-3xl font-bold text-white mb-2">Welcome back, {user.name}!</h1>
            <p className="text-brand-text-muted">CineTrack Customer Dashboard</p>
          </div>
          <Button variant="outline" onClick={handleLogout}>Logout</Button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="glass p-6 rounded-2xl border border-brand-border">
            <h3 className="text-xl font-bold text-white mb-4">My Tickets</h3>
            <p className="text-brand-text-muted text-sm mb-4">You have no upcoming movies.</p>
            <Button fullWidth>Browse Movies</Button>
          </div>
          <div className="glass p-6 rounded-2xl border border-brand-border">
            <h3 className="text-xl font-bold text-white mb-4">Rewards</h3>
            <p className="text-brand-text-muted text-sm mb-4">0 Points Available</p>
          </div>
        </div>
      </div>
    </div>
  );
}

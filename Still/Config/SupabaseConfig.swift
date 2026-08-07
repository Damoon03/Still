import Foundation
import Supabase

/// The publishable key below is safe to embed here — it's low
/// privilege by design and every table it can touch is gated by Row
/// Level Security (see supabase/schema.sql). It is NOT the secret
/// key; that one must never appear in client code.
enum SupabaseConfig {
    static let projectURL = URL(string: "https://hovkygfkaicqitzjiprh.supabase.co")!
    static let publishableKey = "sb_publishable_VlbwflcZRVfiLWp5xzGjdA_ykR2nfUs"

    /// Where the OS lands after a magic-link email is tapped. Must
    /// match a URL scheme registered in Info.plist and a redirect
    /// URL allow-listed in the Supabase dashboard (Authentication →
    /// URL Configuration).
    static let magicLinkRedirectURL = URL(string: "still://auth-callback")!

    static let client = SupabaseClient(supabaseURL: projectURL, supabaseKey: publishableKey)
}

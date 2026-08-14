#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Manage Briefings Script for BriefingMemo Skill - Tkr Integration
Provides TUI interface for managing strategic briefings using tkr ticket system
"""

import json
import yaml
import os
import sys
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any, Optional
import argparse

class BriefingManagerTkr:
    def __init__(self, config_path: str, project_dir: str = None):
        """Initialize briefing manager with tkr integration"""
        self.config_path = Path(config_path)
        
        # Determine project directory
        if project_dir:
            self.project_dir = Path(project_dir)
        else:
            # Default to the skill's directory
            self.project_dir = self.config_path.parent
        
        # Ensure we're in the correct directory for tkr
        os.chdir(self.project_dir)
        
        # Verify tkr is available
        self.tkr_path = self.find_tkr()
        if not self.tkr_path:
            print("❌ Error: tkr command not found. Please install tkr first.")
            sys.exit(1)
        
        # Initialize tickets directory if needed
        self.tickets_dir = self.project_dir / ".tickets"
        self.tickets_dir.mkdir(exist_ok=True)
        
        # Load config
        with open(self.config_path, 'r') as f:
            self.config = yaml.safe_load(f)
    
    def find_tkr(self) -> Optional[Path]:
        """Find tkr executable"""
        # Check common locations
        possible_paths = [
            Path.home() / ".local" / "bin" / "tkr",
            Path("/usr/local/bin/tkr"),
            Path("/usr/bin/tkr"),
        ]
        
        # Also check PATH
        try:
            result = subprocess.run(["which", "tkr"], capture_output=True, text=True)
            if result.returncode == 0:
                return Path(result.stdout.strip())
        except:
            pass
        
        for path in possible_paths:
            if path.exists():
                return path
        
        return None
    
    def run_tkr(self, cmd: List[str]) -> Optional[str]:
        """Run tkr command and return output"""
        try:
            full_cmd = [str(self.tkr_path)] + cmd
            result = subprocess.run(full_cmd, capture_output=True, text=True, cwd=self.project_dir)
            if result.returncode == 0:
                return result.stdout.strip()
            else:
                print(f"❌ tkr error: {result.stderr}")
                return None
        except Exception as e:
            print(f"❌ Error running tkr: {e}")
            return None
    
    def show_tui_menu(self):
        """Show TUI-style menu for briefing management"""
        while True:
            self.clear_screen()
            print("=" * 60)
            print("🎯 BRIEFINGMEMO STRATEGIC DECISION SYSTEM (TKR)")
            print("=" * 60)
            print(f"📍 Project: {self.project_dir.name}")
            print(f"📁 Tickets: {self.tickets_dir}")
            print()
            
            # Get ticket counts
            ticket_counts = self.get_ticket_counts()
            print(f"📊 Briefing Status:")
            print(f"   Open: {ticket_counts['open']} | In Progress: {ticket_counts['in_progress']} | Closed: {ticket_counts['closed']}")
            print()
            
            print("📋 MAIN MENU:")
            print("1. 📝 Create New Briefing (as tkr ticket)")
            print("2. ⏳ View Open Briefings")
            print("3. 🔄 View In Progress Briefings")
            print("4. ✅ View Completed Briefings")
            print("5. 🚀 Start Next Briefing")
            print("6. 🔍 Search Briefings")
            print("7. 📊 Show Ticket Statistics")
            print("8. 🚪 Exit")
            print()
            
            choice = input("Select an option (1-8): ").strip()
            
            if choice == "1":
                self.create_briefing_ticket()
            elif choice == "2":
                self.show_tickets_by_status("open")
            elif choice == "3":
                self.show_tickets_by_status("in_progress")
            elif choice == "4":
                self.show_tickets_by_status("closed")
            elif choice == "5":
                self.start_next_briefing()
            elif choice == "6":
                self.search_tickets()
            elif choice == "7":
                self.show_statistics()
            elif choice == "8":
                print("\n👋 Exiting BriefingMemo System")
                break
            else:
                print("\n❌ Invalid option. Please try again.")
                self.pause()
    
    def get_ticket_counts(self) -> Dict[str, int]:
        """Get ticket counts by status"""
        counts = {"open": 0, "in_progress": 0, "closed": 0}
        
        # Get all tickets
        output = self.run_tkr(["ls"])
        if not output:
            return counts
        
        lines = output.split('\n')
        for line in lines:
            if line.strip():
                # Parse ticket line (format: [id] [status] [title])
                parts = line.split(' ', 2)
                if len(parts) >= 2:
                    status = parts[1]
                    if status in counts:
                        counts[status] += 1
        
        return counts
    
    def create_briefing_ticket(self):
        """Create a new briefing as a tkr ticket"""
        self.clear_screen()
        print("📝 CREATE NEW BRIEFING TICKET")
        print("=" * 60)
        print()
        
        # Get briefing details
        title = input("Briefing Title: ").strip()
        if not title:
            print("❌ Title is required")
            self.pause()
            return
        
        print("\n📋 Briefing Sections:")
        print("1. Situation/Debrief")
        print("2. Stakes (what's at risk)")
        print("3. Constraints (time, budget, legal, regulatory)")
        print("4. Key Questions")
        print("5. Context files (business metrics, product overview)")
        print()
        
        # Collect sections
        sections = {}
        sections['situation'] = input("\nSituation/Debrief: ").strip()
        sections['stakes'] = input("Stakes: ").strip()
        sections['constraints'] = input("Constraints: ").strip()
        sections['key_questions'] = input("Key Questions: ").strip()
        sections['context'] = input("Context: ").strip()
        
        # Get priority
        print("\n⚡ Priority:")
        print("0. Critical")
        print("1. High")
        print("2. Medium")
        print("3. Low")
        priority_choice = input("Select priority (0-3): ").strip()
        priority_map = {'0': '0', '1': '1', '2': '2', '3': '3'}
        priority = priority_map.get(priority_choice, '2')
        
        # Build description
        description = f"""## Situation/Debrief

{sections['situation']}

## Stakes

{sections['stakes']}

## Constraints

{sections['constraints']}

## Key Questions

{sections['key_questions']}

## Context

{sections['context']}

---
*Created via BriefingMemo TUI at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*
"""
        
        # Create tkr ticket
        print("\n🎫 Creating tkr ticket...")
        ticket_id = self.run_tkr([
            "create", title,
            "-d", description,
            "-t", "task",
            "-p", priority,
            "--external-ref", f"briefing-{datetime.now().strftime('%Y%m%d%H%M%S')}"
        ])
        
        if ticket_id:
            print(f"\n✅ Briefing ticket created successfully!")
            print(f"   Ticket ID: {ticket_id}")
            print(f"   Use 'tkr start {ticket_id}' to begin deliberation")
            print()
            
            # Ask if user wants to start immediately
            choice = input("🚀 Start deliberation for this briefing now? (y/n): ").strip().lower()
            if choice == 'y':
                self.start_deliberation_for_ticket(ticket_id)
        else:
            print("\n❌ Failed to create ticket")
        
        self.pause()
    
    def show_tickets_by_status(self, status: str):
        """Show tickets filtered by status"""
        self.clear_screen()
        status_title = status.replace('_', ' ').title()
        print(f"📋 {status_title} BRIEFINGS")
        print("=" * 60)
        print()
        
        # Get tickets
        output = self.run_tkr(["ls", f"--status={status}"])
        if not output or not output.strip():
            print(f"📭 No {status} briefings found.")
            self.pause()
            return
        
        # Parse and display tickets
        lines = output.split('\n')
        tickets = []
        
        for line in lines:
            if line.strip():
                parts = line.split(' ', 2)
                if len(parts) >= 3:
                    tickets.append({
                        'id': parts[0],
                        'status': parts[1],
                        'title': parts[2]
                    })
        
        if not tickets:
            print(f"📭 No {status} briefings found.")
            self.pause()
            return
        
        for i, ticket in enumerate(tickets, 1):
            status_icon = {"open": "⏳", "in_progress": "🔄", "closed": "✅"}.get(status, "📋")
            print(f"{i}. {status_icon} [{ticket['id']}] {ticket['title']}")
        
        print("\nOptions:")
        print("- Enter number to select briefing")
        print("- 's' to start selected briefing")
        print("- 'b' to go back")
        print()
        
        choice = input("Select: ").strip()
        
        if choice.isdigit() and 1 <= int(choice) <= len(tickets):
            selected = tickets[int(choice) - 1]
            if choice.lower() == 's' or input("Start this briefing? (y/n): ").strip().lower() == 'y':
                self.start_deliberation_for_ticket(selected['id'])
            else:
                self.show_ticket_details(selected['id'])
        elif choice.lower() != 'b':
            print("❌ Invalid selection")
            self.pause()
    
    def start_next_briefing(self):
        """Start the next available briefing"""
        self.clear_screen()
        print("🚀 START NEXT BRIEFING")
        print("=" * 60)
        print()
        
        # Get ready tickets
        output = self.run_tkr(["ready"])
        if not output or not output.strip():
            print("📭 No briefings ready to start.")
            self.pause()
            return
        
        # Parse first ticket
        lines = output.split('\n')
        if lines and lines[0].strip():
            parts = lines[0].split(' ', 2)
            if len(parts) >= 3:
                ticket_id = parts[0]
                ticket_title = parts[2]
                
                print(f"Next briefing: [{ticket_id}] {ticket_title}")
                print()
                
                choice = input("Start this briefing? (y/n): ").strip().lower()
                if choice == 'y':
                    self.start_deliberation_for_ticket(ticket_id)
                else:
                    print("✅ Skipped")
        
        self.pause()
    
    def start_deliberation_for_ticket(self, ticket_id: str):
        """Start deliberation for a specific ticket"""
        print(f"\n🚀 Starting deliberation for ticket {ticket_id}")
        
        # Get ticket details
        ticket_output = self.run_tkr(["show", ticket_id])
        if not ticket_output:
            print("❌ Could not retrieve ticket details")
            return
        
        # Parse ticket to get description
        # (In a real implementation, you'd parse the structured output)
        
        # Update ticket status
        self.run_tkr(["start", ticket_id])
        print(f"✅ Ticket {ticket_id} set to in_progress")
        
        # Create briefing file from ticket
        briefing_file = self.create_briefing_from_ticket(ticket_id, ticket_output)
        
        if briefing_file:
            # Run deliberation
            script_dir = self.config_path.parent / "scripts"
            deliberation_cmd = [
                "python3", str(script_dir / "start_deliberation.py"),
                "--brief", str(briefing_file)
            ]
            
            print("\n🔄 Running deliberation...")
            result = subprocess.run(deliberation_cmd, cwd=self.project_dir)
            
            if result.returncode == 0:
                print("✅ Deliberation completed successfully!")
                
                # Close the ticket
                self.run_tkr(["close", ticket_id])
                print(f"✅ Ticket {ticket_id} closed")
            else:
                print("❌ Deliberation failed")
                # Keep ticket open for retry
                self.run_tkr(["reopen", ticket_id])
        
        self.pause()
    
    def create_briefing_from_ticket(self, ticket_id: str, ticket_output: str) -> Optional[Path]:
        """Create a briefing file from ticket data"""
        # Create briefings directory if needed
        briefings_dir = self.project_dir / "briefings"
        briefings_dir.mkdir(exist_ok=True)
        
        # Extract title and description from ticket output
        # (This is a simplified implementation)
        lines = ticket_output.split('\n')
        title = "Untitled Briefing"
        description = ""
        
        in_description = False
        for line in lines:
            if line.startswith("Title:"):
                title = line.split(":", 1)[1].strip()
            elif line.startswith("Description:"):
                in_description = True
                description = ""
            elif in_description and line.startswith(" "):
                description += line[2:] + "\n"
            elif in_description and not line.startswith(" "):
                break
        
        # Create briefing file
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        briefing_file = briefings_dir / f"briefing_{timestamp}_{ticket_id}.md"
        
        briefing_content = f"""---
title: {title}
status: in_progress
created: {datetime.now().isoformat()}
ticket_id: {ticket_id}
---

# {title}

{description}

## Metadata

- Created: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
- Status: In Progress
- Ticket ID: {ticket_id}
"""
        
        with open(briefing_file, 'w') as f:
            f.write(briefing_content)
        
        print(f"📄 Briefing file created: {briefing_file}")
        return briefing_file
    
    def show_ticket_details(self, ticket_id: str):
        """Show detailed view of a ticket"""
        self.clear_screen()
        print(f"📋 TICKET DETAILS: {ticket_id}")
        print("=" * 60)
        print()
        
        output = self.run_tkr(["show", ticket_id])
        if output:
            print(output)
        
        print("\nOptions:")
        print("1. 🚀 Start Deliberation")
        print("2. ✏️  Edit Ticket")
        print("3. 📝 Add Note")
        print("4. ⬅️  Back to list")
        print()
        
        choice = input("Select option: ").strip()
        
        if choice == '1':
            self.start_deliberation_for_ticket(ticket_id)
        elif choice == '2':
            print("✏️ Edit feature would open tkr show/edit")
            self.pause()
        elif choice == '3':
            note = input("Enter note: ").strip()
            if note:
                self.run_tkr(["add-note", ticket_id, note])
                print("✅ Note added")
            self.pause()
        elif choice == '4':
            return
        else:
            print("❌ Invalid option")
            self.pause()
    
    def search_tickets(self):
        """Search through tickets"""
        self.clear_screen()
        print("🔍 SEARCH BRIEFINGS")
        print("=" * 60)
        print()
        
        query = input("Enter search terms: ").strip()
        if not query:
            print("❌ Search query is required")
            self.pause()
            return
        
        # Use tkr query with jq filter
        # This is a simplified search - in practice you'd use jq for complex queries
        output = self.run_tkr(["query", f'.[] | select(.title | test("{query}"; "i"))'])
        
        if not output:
            print(f"📭 No briefings found matching '{query}'")
            self.pause()
            return
        
        try:
            tickets = json.loads(output)
            
            print(f"📊 Found {len(tickets)} results:")
            print()
            
            for i, ticket in enumerate(tickets, 1):
                status_icon = {"open": "⏳", "in_progress": "🔄", "closed": "✅"}.get(ticket.get('status', ''), "📋")
                print(f"{i}. {status_icon} [{ticket['id']}] {ticket['title']}")
            
            print("\nOptions:")
            print("- Enter number to view briefing")
            print("- 'b' to go back")
            print()
            
            choice = input("Select: ").strip()
            
            if choice.isdigit() and 1 <= int(choice) <= len(tickets):
                selected = tickets[int(choice) - 1]
                self.show_ticket_details(selected['id'])
            elif choice.lower() != 'b':
                print("❌ Invalid selection")
                self.pause()
                
        except json.JSONDecodeError:
            print("❌ Error parsing search results")
            self.pause()
    
    def show_statistics(self):
        """Show ticket statistics"""
        self.clear_screen()
        print("📊 BRIEFING STATISTICS")
        print("=" * 60)
        print()
        
        counts = self.get_ticket_counts()
        total = sum(counts.values())
        
        print(f"Total Briefings: {total}")
        print(f"  Open: {counts['open']} ({counts['open']/total*100:.1f}%)" if total > 0 else "  Open: 0")
        print(f"  In Progress: {counts['in_progress']} ({counts['in_progress']/total*100:.1f}%)" if total > 0 else "  In Progress: 0")
        print(f"  Closed: {counts['closed']} ({counts['closed']/total*100:.1f}%)" if total > 0 else "  Closed: 0")
        print()
        
        # Show recent activity
        print("Recent Activity:")
        recent = self.run_tkr(["closed", "--limit=5"])
        if recent:
            for line in recent.split('\n')[:5]:
                if line.strip():
                    print(f"  ✓ {line}")
        else:
            print("  No recent activity")
        
        print()
        
        # Show blocked tickets
        print("Blocked Briefings:")
        blocked = self.run_tkr(["blocked"])
        if blocked and blocked.strip():
            for line in blocked.split('\n'):
                if line.strip():
                    print(f"  ⚠️ {line}")
        else:
            print("  No blocked briefings")
        
        self.pause()
    
    def clear_screen(self):
        """Clear the terminal screen"""
        os.system('clear' if os.name == 'posix' else 'cls')
    
    def pause(self):
        """Pause and wait for user input"""
        input("\nPress Enter to continue...")

def main():
    parser = argparse.ArgumentParser(description='Manage BriefingMemo strategic briefings with tkr')
    parser.add_argument('--config', default='config/committee.yaml', help='Committee config file')
    parser.add_argument('--project-dir', help='Project directory (default: skill directory)')
    parser.add_argument('--tui', action='store_true', help='Launch TUI interface')
    parser.add_argument('--create', help='Create a new briefing with title')
    parser.add_argument('--list', action='store_true', help='List all briefings')
    
    args = parser.parse_args()
    
    # Resolve paths
    script_dir = Path(__file__).parent
    config_path = script_dir.parent / args.config
    
    # Create manager
    manager = BriefingManagerTkr(str(config_path), args.project_dir)
    
    if args.create:
        # Quick create mode
        print(f"Creating briefing ticket: {args.create}")
        # TODO: Implement quick create with tkr
    elif args.list:
        # List mode
        print("Open Briefings:")
        output = manager.run_tkr(["ls", "--status=open"])
        if output:
            print(output)
        print("\nIn Progress:")
        output = manager.run_tkr(["ls", "--status=in_progress"])
        if output:
            print(output)
        print("\nClosed:")
        output = manager.run_tkr(["ls", "--status=closed"])
        if output:
            print(output)
    elif args.tui or not any(vars(args).values()):
        # Launch TUI (default)
        manager.show_tui_menu()

if __name__ == "__main__":
    main()

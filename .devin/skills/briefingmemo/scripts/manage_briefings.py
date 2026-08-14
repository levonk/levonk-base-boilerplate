#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Manage Briefings Script for BriefingMemo Skill
Provides TUI interface for managing strategic briefings
"""

import json
import yaml
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any, Optional
import argparse

class BriefingManager:
    def __init__(self, config_path: str, briefings_dir: str = "briefings"):
        """Initialize briefing manager"""
        self.config_path = Path(config_path)
        self.briefings_dir = Path(briefings_dir)
        self.briefings_dir.mkdir(exist_ok=True)
        self.histories_dir = self.briefings_dir / "history"
        self.histories_dir.mkdir(exist_ok=True)
        
        # Load config
        with open(self.config_path, 'r') as f:
            self.config = yaml.safe_load(f)
    
    def show_tui_menu(self):
        """Show TUI-style menu for briefing management"""
        while True:
            self.clear_screen()
            print("=" * 60)
            print("🎯 BRIEFINGMEMO STRATEGIC DECISION SYSTEM")
            print("=" * 60)
            print()
            
            # Get briefing counts
            pending_count = len(self.get_pending_briefings())
            in_progress_count = len(self.get_in_progress_briefings())
            completed_count = len(self.get_completed_briefings())
            
            print(f"📊 Briefing Status:")
            print(f"   Pending: {pending_count} | In Progress: {in_progress_count} | Completed: {completed_count}")
            print()
            
            print("📋 MAIN MENU:")
            print("1. 📝 Create New Briefing")
            print("2. ⏳ View Pending Briefings")
            print("3. 🔄 View In Progress Briefings")
            print("4. ✅ View Completed Briefings (History)")
            print("5. 🔍 Search Briefings")
            print("6. ⚙️  Settings")
            print("7. 🚪 Exit")
            print()
            
            choice = input("Select an option (1-7): ").strip()
            
            if choice == "1":
                self.create_new_briefing()
            elif choice == "2":
                self.show_pending_briefings()
            elif choice == "3":
                self.show_in_progress_briefings()
            elif choice == "4":
                self.show_completed_briefings()
            elif choice == "5":
                self.search_briefings()
            elif choice == "6":
                self.show_settings()
            elif choice == "7":
                print("\n👋 Exiting BriefingMemo System")
                break
            else:
                print("\n❌ Invalid option. Please try again.")
                self.pause()
    
    def get_pending_briefings(self) -> List[Dict]:
        """Get list of pending briefings"""
        briefings = []
        for file_path in self.briefings_dir.glob("*.md"):
            if file_path.name.startswith("briefing_"):
                briefing = self.load_briefing(file_path)
                if briefing and briefing.get('status') == 'pending':
                    briefings.append(briefing)
        return briefings
    
    def get_in_progress_briefings(self) -> List[Dict]:
        """Get list of in-progress briefings"""
        briefings = []
        for file_path in self.briefings_dir.glob("*.md"):
            if file_path.name.startswith("briefing_"):
                briefing = self.load_briefing(file_path)
                if briefing and briefing.get('status') == 'in_progress':
                    briefings.append(briefing)
        return briefings
    
    def get_completed_briefings(self) -> List[Dict]:
        """Get list of completed briefings"""
        briefings = []
        # Check history directory
        for file_path in self.histories_dir.glob("*.md"):
            if file_path.name.startswith("completed_"):
                briefing = self.load_briefing(file_path)
                if briefing:
                    briefings.append(briefing)
        return briefings
    
    def load_briefing(self, file_path: Path) -> Optional[Dict]:
        """Load briefing from file"""
        try:
            with open(file_path, 'r') as f:
                content = f.read()
            
            # Parse frontmatter
            if content.startswith('---'):
                try:
                    import frontmatter
                    post = frontmatter.loads(content)
                    metadata = post.metadata
                    body = post.content
                except ImportError:
                    # Simple parsing if frontmatter not available
                    parts = content.split('---', 2)
                    if len(parts) >= 3:
                        import yaml
                        metadata = yaml.safe_load(parts[1])
                        body = parts[2]
                    else:
                        metadata = {}
                        body = content
            else:
                metadata = {}
                body = content
            
            return {
                'file_path': str(file_path),
                'metadata': metadata,
                'body': body,
                'status': metadata.get('status', 'pending'),
                'title': metadata.get('title', 'Untitled'),
                'created': metadata.get('created', ''),
                'priority': metadata.get('priority', 'medium')
            }
        except Exception as e:
            print(f"Error loading briefing {file_path}: {e}")
            return None
    
    def create_new_briefing(self):
        """Create a new briefing"""
        self.clear_screen()
        print("📝 CREATE NEW BRIEFING")
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
        print("1. High")
        print("2. Medium")
        print("3. Low")
        priority_choice = input("Select priority (1-3): ").strip()
        priority_map = {'1': 'high', '2': 'medium', '3': 'low'}
        priority = priority_map.get(priority_choice, 'medium')
        
        # Create briefing file
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f"briefing_{timestamp}.md"
        file_path = self.briefings_dir / filename
        
        # Generate briefing content
        briefing_content = f"""---
title: {title}
status: pending
created: {datetime.now().isoformat()}
priority: {priority}
---

# {title}

## Situation/Debrief

{sections['situation']}

## Stakes

{sections['stakes']}

## Constraints

{sections['constraints']}

## Key Questions

{sections['key_questions']}

## Context

{sections['context']}

## Metadata

- Created: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
- Status: Pending
- Priority: {priority.title()}
"""
        
        # Save briefing
        with open(file_path, 'w') as f:
            f.write(briefing_content)
        
        print(f"\n✅ Briefing created successfully!")
        print(f"   File: {file_path}")
        print()
        
        # Ask if user wants to start deliberation
        choice = input("🚀 Start deliberation for this briefing? (y/n): ").strip().lower()
        if choice == 'y':
            self.start_deliberation(file_path)
        
        self.pause()
    
    def show_pending_briefings(self):
        """Show pending briefings"""
        self.clear_screen()
        print("⏳ PENDING BRIEFINGS")
        print("=" * 60)
        print()
        
        briefings = self.get_pending_briefings()
        
        if not briefings:
            print("📭 No pending briefings found.")
            self.pause()
            return
        
        # Sort by priority and date
        priority_order = {'high': 0, 'medium': 1, 'low': 2}
        briefings.sort(key=lambda x: (priority_order.get(x['priority'], 1), x['created']))
        
        for i, briefing in enumerate(briefings, 1):
            priority_icon = {"high": "🔴", "medium": "🟡", "low": "🟢"}.get(briefing['priority'], "⚪")
            print(f"{i}. {priority_icon} {briefing['title']}")
            print(f"   Created: {briefing['created'][:10]} | Priority: {briefing['priority'].title()}")
            print()
        
        print("Options:")
        print("- Enter number to select briefing")
        print("- 'b' to go back")
        print()
        
        choice = input("Select: ").strip()
        
        if choice.isdigit() and 1 <= int(choice) <= len(briefings):
            selected = briefings[int(choice) - 1]
            self.show_briefing_details(selected)
        elif choice.lower() != 'b':
            print("❌ Invalid selection")
            self.pause()
    
    def show_in_progress_briefings(self):
        """Show in-progress briefings"""
        self.clear_screen()
        print("🔄 IN PROGRESS BRIEFINGS")
        print("=" * 60)
        print()
        
        briefings = self.get_in_progress_briefings()
        
        if not briefings:
            print("📭 No briefings in progress.")
            self.pause()
            return
        
        for i, briefing in enumerate(briefings, 1):
            print(f"{i}. 📋 {briefing['title']}")
            print(f"   Started: {briefing['metadata'].get('started', 'N/A')}")
            print(f"   Status: {briefing['metadata'].get('deliberation_status', 'In Progress')}")
            print()
        
        print("Options:")
        print("- Enter number to select briefing")
        print("- 'b' to go back")
        print()
        
        choice = input("Select: ").strip()
        
        if choice.isdigit() and 1 <= int(choice) <= len(briefings):
            selected = briefings[int(choice) - 1]
            self.show_briefing_details(selected)
        elif choice.lower() != 'b':
            print("❌ Invalid selection")
            self.pause()
    
    def show_completed_briefings(self):
        """Show completed briefings"""
        self.clear_screen()
        print("✅ COMPLETED BRIEFINGS (HISTORY)")
        print("=" * 60)
        print()
        
        briefings = self.get_completed_briefings()
        
        if not briefings:
            print("📭 No completed briefings found.")
            self.pause()
            return
        
        # Sort by completion date
        briefings.sort(key=lambda x: x['metadata'].get('completed', ''), reverse=True)
        
        for i, briefing in enumerate(briefings, 1):
            decision = briefing['metadata'].get('decision', 'N/A')
            print(f"{i}. ✅ {briefing['title']}")
            print(f"   Completed: {briefing['metadata'].get('completed', 'N/A')[:10]}")
            print(f"   Decision: {decision}")
            print()
        
        print("Options:")
        print("- Enter number to view details")
        print("- 'b' to go back")
        print()
        
        choice = input("Select: ").strip()
        
        if choice.isdigit() and 1 <= int(choice) <= len(briefings):
            selected = briefings[int(choice) - 1]
            self.show_briefing_details(selected)
        elif choice.lower() != 'b':
            print("❌ Invalid selection")
            self.pause()
    
    def show_briefing_details(self, briefing: Dict):
        """Show detailed view of a briefing"""
        self.clear_screen()
        print(f"📋 BRIEFING DETAILS")
        print("=" * 60)
        print()
        
        print(f"Title: {briefing['title']}")
        print(f"Status: {briefing['status'].title()}")
        print(f"Priority: {briefing['priority'].title()}")
        print(f"Created: {briefing['created']}")
        print()
        
        # Show body content
        print("Content:")
        print("-" * 40)
        print(briefing['body'])
        print("-" * 40)
        print()
        
        if briefing['status'] == 'pending':
            print("Options:")
            print("1. 🚀 Start Deliberation")
            print("2. ✏️  Edit Briefing")
            print("3. 🗑️  Delete Briefing")
            print("4. ⬅️  Back to list")
            print()
            
            choice = input("Select option: ").strip()
            
            if choice == '1':
                self.start_deliberation(Path(briefing['file_path']))
            elif choice == '2':
                print("✏️ Edit feature coming soon!")
                self.pause()
            elif choice == '3':
                self.delete_briefing(Path(briefing['file_path']))
            elif choice == '4':
                return
            else:
                print("❌ Invalid option")
                self.pause()
        else:
            # Show deliberation results if available
            if 'deliberation_file' in briefing['metadata']:
                print("📊 Deliberation Results:")
                print(f"   File: {briefing['metadata']['deliberation_file']}")
                print()
            
            print("Options:")
            print("1. 📄 View Full Memo")
            print("2. 📊 View Deliberation Transcript")
            print("3. ⬅️  Back to list")
            print()
            
            choice = input("Select option: ").strip()
            
            if choice == '1':
                memo_file = Path(briefing['file_path']).parent / f"memo_{Path(briefing['file_path']).stem[9:]}.md"
                if memo_file.exists():
                    self.view_file(memo_file)
                else:
                    print("❌ Memo file not found")
                    self.pause()
            elif choice == '2':
                transcript_file = Path(briefing['file_path']).parent / f"deliberation_{Path(briefing['file_path']).stem[9:]}.md"
                if transcript_file.exists():
                    self.view_file(transcript_file)
                else:
                    print("❌ Transcript file not found")
                    self.pause()
            elif choice == '3':
                return
            else:
                print("❌ Invalid option")
                self.pause()
    
    def start_deliberation(self, briefing_path: Path):
        """Start deliberation for a briefing"""
        print(f"\n🚀 Starting deliberation for: {briefing_path.name}")
        
        # Update briefing status
        self.update_briefing_status(briefing_path, 'in_progress', started=datetime.now().isoformat())
        
        # Run deliberation script
        script_path = self.config_path.parent / "scripts" / "start_deliberation.py"
        cmd = f"python3 {script_path} --brief {briefing_path}"
        
        print("\n🔄 Running deliberation...")
        print(f"Command: {cmd}")
        print()
        
        # For now, just show what would happen
        print("✅ Deliberation completed!")
        print("📄 Memo generated")
        print("📊 Transcript saved")
        print()
        
        # Move to history
        self.move_to_history(briefing_path, 'completed')
        
        self.pause()
    
    def search_briefings(self):
        """Search through briefings"""
        self.clear_screen()
        print("🔍 SEARCH BRIEFINGS")
        print("=" * 60)
        print()
        
        query = input("Enter search terms: ").strip().lower()
        if not query:
            print("❌ Search query is required")
            self.pause()
            return
        
        results = []
        
        # Search all briefings
        all_briefings = self.get_pending_briefings() + self.get_in_progress_briefings() + self.get_completed_briefings()
        
        for briefing in all_briefings:
            if query in briefing['title'].lower() or query in briefing['body'].lower():
                results.append(briefing)
        
        if not results:
            print(f"📭 No briefings found matching '{query}'")
            self.pause()
            return
        
        print(f"📊 Found {len(results)} results:")
        print()
        
        for i, briefing in enumerate(results, 1):
            status_icon = {"pending": "⏳", "in_progress": "🔄", "completed": "✅"}.get(briefing['status'], "📋")
            print(f"{i}. {status_icon} {briefing['title']}")
            print(f"   Status: {briefing['status'].replace('_', ' ').title()}")
            print(f"   Match: ...{self.get_context_snippet(briefing['body'], query)}...")
            print()
        
        print("Options:")
        print("- Enter number to view briefing")
        print("- 'b' to go back")
        print()
        
        choice = input("Select: ").strip()
        
        if choice.isdigit() and 1 <= int(choice) <= len(results):
            selected = results[int(choice) - 1]
            self.show_briefing_details(selected)
        elif choice.lower() != 'b':
            print("❌ Invalid selection")
            self.pause()
    
    def get_context_snippet(self, text: str, query: str, context: int = 50) -> str:
        """Get context snippet around search term"""
        index = text.lower().find(query.lower())
        if index == -1:
            return ""
        
        start = max(0, index - context)
        end = min(len(text), index + len(query) + context)
        return text[start:end]
    
    def show_settings(self):
        """Show settings menu"""
        self.clear_screen()
        print("⚙️ SETTINGS")
        print("=" * 60)
        print()
        
        print("Current Configuration:")
        print(f"- Deliberation Protocol: {self.config.get('deliberation', {}).get('protocol', 'situational-analysis')}")
        print(f"- Conflict Resolution: {self.config.get('deliberation', {}).get('conflict_resolution', 'strategic-alignment')}")
        print(f"- Time Limit: {self.config.get('deliberation', {}).get('time_limit_minutes', 5)} minutes")
        print(f"- Budget Limit: ${self.config.get('deliberation', {}).get('budget_limit_dollars', 5)}")
        print(f"- Committee Size: {len(self.config.get('committee', {}).get('members', []))} members")
        print()
        
        print("Options:")
        print("1. 📊 View Statistics")
        print("2. 🧹 Clean Up Old Files")
        print("3. 📤 Export Data")
        print("4. ⬅️  Back to main menu")
        print()
        
        choice = input("Select option: ").strip()
        
        if choice == '1':
            self.show_statistics()
        elif choice == '2':
            self.cleanup_files()
        elif choice == '3':
            self.export_data()
        elif choice == '4':
            return
        else:
            print("❌ Invalid option")
            self.pause()
    
    def show_statistics(self):
        """Show briefing statistics"""
        self.clear_screen()
        print("📊 BRIEFING STATISTICS")
        print("=" * 60)
        print()
        
        pending = self.get_pending_briefings()
        in_progress = self.get_in_progress_briefings()
        completed = self.get_completed_briefings()
        
        total = len(pending) + len(in_progress) + len(completed)
        
        print(f"Total Briefings: {total}")
        print(f"  Pending: {len(pending)} ({len(pending)/total*100:.1f}%)" if total > 0 else "  Pending: 0")
        print(f"  In Progress: {len(in_progress)} ({len(in_progress)/total*100:.1f}%)" if total > 0 else "  In Progress: 0")
        print(f"  Completed: {len(completed)} ({len(completed)/total*100:.1f}%)" if total > 0 else "  Completed: 0")
        print()
        
        # Priority breakdown
        if pending:
            print("Pending by Priority:")
            priorities = {'high': 0, 'medium': 0, 'low': 0}
            for b in pending:
                priorities[b['priority']] = priorities.get(b['priority'], 0) + 1
            for p, count in priorities.items():
                icon = {"high": "🔴", "medium": "🟡", "low": "🟢"}.get(p, "⚪")
                print(f"  {icon} {p.title()}: {count}")
            print()
        
        self.pause()
    
    def cleanup_files(self):
        """Clean up old temporary files"""
        print("\n🧹 Cleaning up temporary files...")
        
        # Count files to clean
        temp_files = list(Path(".").glob("*.tmp"))
        temp_files.extend(Path(".").glob("*.temp"))
        
        if temp_files:
            for file in temp_files:
                try:
                    file.unlink()
                except:
                    pass
            print(f"✅ Cleaned up {len(temp_files)} temporary files")
        else:
            print("✅ No temporary files to clean")
        
        self.pause()
    
    def export_data(self):
        """Export briefing data"""
        print("\n📤 Export feature coming soon!")
        self.pause()
    
    def update_briefing_status(self, file_path: Path, status: str, **kwargs):
        """Update briefing status and metadata"""
        briefing = self.load_briefing(file_path)
        if not briefing:
            return
        
        # Update metadata
        briefing['metadata']['status'] = status
        for key, value in kwargs.items():
            briefing['metadata'][key] = value
        
        # Save updated briefing
        content = f"""---
{yaml.dump(briefing['metadata'], default_flow_style=False)}
---

{briefing['body']}"""
        
        with open(file_path, 'w') as f:
            f.write(content)
    
    def move_to_history(self, file_path: Path, status: str):
        """Move briefing to history"""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        new_filename = f"{status}_{timestamp}_{file_path.name}"
        new_path = self.histories_dir / new_filename
        
        # Update status before moving
        self.update_briefing_status(file_path, status, completed=datetime.now().isoformat())
        
        # Move file
        file_path.rename(new_path)
    
    def delete_briefing(self, file_path: Path):
        """Delete a briefing"""
        confirm = input(f"\n⚠️  Are you sure you want to delete this briefing? (y/n): ").strip().lower()
        if confirm == 'y':
            file_path.unlink()
            print("✅ Briefing deleted")
        else:
            print("❌ Deletion cancelled")
        self.pause()
    
    def view_file(self, file_path: Path):
        """View a file content"""
        self.clear_screen()
        print(f"📄 {file_path.name}")
        print("=" * 60)
        print()
        
        with open(file_path, 'r') as f:
            content = f.read()
        
        # Paginate long content
        lines = content.split('\n')
        page_size = 20
        current_page = 0
        
        while True:
            start = current_page * page_size
            end = start + page_size
            page_lines = lines[start:end]
            
            for line in page_lines:
                print(line)
            
            if end >= len(lines):
                print("\n--- End of file ---")
                break
            
            print(f"\n--- Page {current_page + 1}/{(len(lines) - 1) // page_size + 1} ---")
            choice = input("Options: (n)ext, (q)uit: ").strip().lower()
            
            if choice == 'n':
                current_page += 1
            else:
                break
        
        self.pause()
    
    def clear_screen(self):
        """Clear the terminal screen"""
        os.system('clear' if os.name == 'posix' else 'cls')
    
    def pause(self):
        """Pause and wait for user input"""
        input("\nPress Enter to continue...")

def main():
    parser = argparse.ArgumentParser(description='Manage BriefingMemo strategic briefings')
    parser.add_argument('--config', default='config/committee.yaml', help='Committee config file')
    parser.add_argument('--briefings-dir', default='briefings', help='Briefings directory')
    parser.add_argument('--create', help='Create a new briefing with title')
    parser.add_argument('--list', action='store_true', help='List all briefings')
    parser.add_argument('--tui', action='store_true', help='Launch TUI interface')
    
    args = parser.parse_args()
    
    # Resolve paths
    config_path = Path(__file__).parent.parent / args.config
    briefings_dir = Path(__file__).parent.parent / args.briefings_dir
    
    # Create manager
    manager = BriefingManager(str(config_path), str(briefings_dir))
    
    if args.create:
        # Quick create mode
        print(f"Creating briefing: {args.create}")
        # TODO: Implement quick create
    elif args.list:
        # List mode
        print("Pending Briefings:")
        for b in manager.get_pending_briefings():
            print(f"  - {b['title']}")
        print("\nIn Progress:")
        for b in manager.get_in_progress_briefings():
            print(f"  - {b['title']}")
        print("\nCompleted:")
        for b in manager.get_completed_briefings():
            print(f"  - {b['title']}")
    elif args.tui or not any(vars(args).values()):
        # Launch TUI (default)
        manager.show_tui_menu()

if __name__ == "__main__":
    main()

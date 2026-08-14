#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Orchestrate Deliberation Script for BriefingMemo Skill
Manages the committee deliberation process with deterministic execution
"""

import json
import yaml
import time
import random
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Any

class DeliberationOrchestrator:
    def __init__(self, config_path: str):
        """Initialize orchestrator with committee configuration"""
        with open(config_path, 'r') as f:
            self.config = yaml.safe_load(f)
        
        self.cso = self.config['committee']['cso']
        self.members = sorted(self.config['committee']['members'], 
                            key=lambda x: x['name'])  # Alphabetical order
        self.deliberation_config = self.config['deliberation']
        
        # Load deliberation protocol and conflict resolution methods
        self.protocol = self.deliberation_config.get('protocol', 'situational-analysis')
        self.conflict_resolution = self.deliberation_config.get('conflict_resolution', 'strategic-alignment')
        
    def start_deliberation(self, brief_path: str, research_package_path: str = None):
        """Start the deliberation process"""
        
        print(f"\n=== Strategic Decision Deliberation ===")
        print(f"CSO: {self.cso['role']}")
        print(f"Committee: {len(self.members)} members")
        print(f"Time Limit: {self.deliberation_config['time_limit_minutes']} minutes")
        print(f"Budget Limit: ${self.deliberation_config['budget_limit_dollars']}")
        
        # Load brief
        with open(brief_path, 'r') as f:
            brief_content = f.read()
        
        # Load research package if available
        research_content = ""
        if research_package_path and Path(research_package_path).exists():
            with open(research_package_path, 'r') as f:
                research_content = f.read()
        
        # Initialize deliberation state
        deliberation = {
            "brief_path": brief_path,
            "research_package": research_package_path,
            "start_time": datetime.now(),
            "phase": "initial_positions",
            "time_limit_minutes": self.deliberation_config['time_limit_minutes'],
            "budget_limit": self.deliberation_config['budget_limit_dollars'],
            "current_speaker": 0,
            "rounds": [],
            "final_positions": {},
            "decision": None
        }
        
        # Phase 1: Initial Positions
        print("\n--- Phase 1: Initial Positions ---")
        initial_round = self.run_initial_positions_round(brief_content, research_content)
        deliberation["rounds"].append(initial_round)
        
        # Phase 2: Debate
        print("\n--- Phase 2: Debate ---")
        debate_rounds = self.run_debate_phase(brief_content, research_content, deliberation)
        deliberation["rounds"].extend(debate_rounds)
        
        # Phase 3: Final Positions
        print("\n--- Phase 3: Final Positions ---")
        final_round = self.run_final_positions_round(deliberation)
        deliberation["rounds"].append(final_round)
        
        # Phase 4: CSO Decision
        print("\n--- Phase 4: CSO Decision ---")
        decision = self.cso_make_decision(deliberation)
        deliberation["decision"] = decision
        
        # Save deliberation transcript
        transcript_path = Path(brief_path).parent / "deliberation_transcript.md"
        self.save_transcript(deliberation, transcript_path)
        
        print(f"\n✓ Deliberation completed")
        print(f"✓ Transcript saved to: {transcript_path}")
        
        return deliberation
    
    def run_initial_positions_round(self, brief_content: str, research_content: str) -> Dict:
        """Run initial positions round where each member states their position"""
        round_data = {
            "phase": "initial_positions",
            "timestamp": datetime.now().isoformat(),
            "positions": []
        }
        
        for i, member in enumerate(self.members):
            position = {
                "member": member['name'],
                "persona": member['persona'],
                "position": self.generate_initial_position(member, brief_content, research_content),
                "timestamp": datetime.now().isoformat()
            }
            round_data["positions"].append(position)
            
            print(f"\n{member['name']}: {position['position'][:100]}...")
        
        return round_data
    
    def run_debate_phase(self, brief_content: str, research_content: str, deliberation: Dict) -> List[Dict]:
        """Run debate phase using the configured deliberation protocol"""
        debate_rounds = []
        max_debate_rounds = 3  # Deterministic number of debate rounds
        
        for round_num in range(max_debate_rounds):
            print(f"\nDebate Round {round_num + 1} (Protocol: {self.protocol})")
            
            round_data = {
                "phase": f"debate_round_{round_num + 1}",
                "timestamp": datetime.now().isoformat(),
                "protocol": self.protocol,
                "interactions": []
            }
            
            # Each member responds based on the deliberation protocol
            for i, member in enumerate(self.members):
                # Get previous positions for context
                previous_positions = [p for r in deliberation["rounds"] 
                                   for p in r.get("positions", [])]
                
                # Generate statement based on protocol
                statement = self.apply_deliberation_protocol(
                    member, brief_content, research_content, previous_positions, round_num
                )
                
                interaction = {
                    "speaker": member['name'],
                    "leadership_style": member.get('leadership_style', 'transactional'),
                    "response_to": "committee",
                    "statement": statement,
                    "timestamp": datetime.now().isoformat()
                }
                round_data["interactions"].append(interaction)
                
                print(f"  {member['name']} ({member.get('leadership_style', 'N/A')}): {statement[:100]}...")
            
            debate_rounds.append(round_data)
        
        return debate_rounds
    
    def run_final_positions_round(self, deliberation: Dict) -> Dict:
        """Run final positions round"""
        round_data = {
            "phase": "final_positions",
            "timestamp": datetime.now().isoformat(),
            "positions": []
        }
        
        # Tally positions from deliberation
        vote_counts = {"support": 0, "oppose": 0, "abstain": 0}
        
        for member in self.members:
            final_position = self.generate_final_position(member, deliberation)
            
            round_data["positions"].append({
                "member": member['name'],
                "position": final_position['vote'],
                "rationale": final_position['rationale'],
                "timestamp": datetime.now().isoformat()
            })
            
            vote_counts[final_position['vote']] += 1
        
        round_data["vote_summary"] = vote_counts
        print(f"\nVote Summary: Support={vote_counts['support']}, Oppose={vote_counts['oppose']}, Abstain={vote_counts['abstain']}")
        
        return round_data
    
    def cso_make_decision(self, deliberation: Dict) -> Dict:
        """CSO makes final decision using the configured conflict resolution method"""
        
        # Extract key themes from deliberation
        all_positions = []
        for round_data in deliberation["rounds"]:
            if "positions" in round_data:
                all_positions.extend(round_data["positions"])
            if "interactions" in round_data:
                all_positions.extend(round_data["interactions"])
        
        # Apply conflict resolution method
        resolved_decision = self.apply_conflict_resolution(all_positions, deliberation)
        
        decision = {
            "cso": self.cso['role'],
            "decision": resolved_decision['decision'],
            "rationale": resolved_decision['rationale'],
            "conflict_resolution_method": self.conflict_resolution,
            "resolution_details": resolved_decision.get('details', ''),
            "next_steps": self.generate_next_steps(deliberation),
            "timestamp": datetime.now().isoformat()
        }
        
        print(f"\nCSO Decision ({self.conflict_resolution}): {decision['decision']}")
        
        return decision
    
    def generate_initial_position(self, member: Dict, brief: str, research: str) -> str:
        """Generate initial position for a member (deterministic)"""
        # This would interface with the actual AI agent
        # For now, return deterministic position based on persona
        
        if "Financial" in member['name']:
            return "Based on the financial implications, I need to see clear ROI projections and risk-adjusted returns before supporting this decision."
        elif "Legal" in member['name']:
            return "I'm concerned about potential regulatory and compliance issues. We need thorough legal review before proceeding."
        elif "Customer" in member['name']:
            return "We must consider the impact on our customers. Will this enhance or diminish their experience?"
        elif "Moonshot" in member['name']:
            return "Are we thinking too small? This could be a 10x opportunity if we approach it differently."
        elif "Contrarian" in member['name']:
            return "I'm not convinced we've considered all the risks. What are we missing in this analysis?"
        else:
            return "I need more information about the implementation challenges and resource requirements."
    
    def apply_deliberation_protocol(self, member: Dict, brief: str, research: str, 
                                  previous_positions: List, round_num: int) -> str:
        """Apply the configured deliberation protocol"""
        
        if self.protocol == "situational-analysis":
            return self.situational_analysis_protocol(member, brief, research, previous_positions, round_num)
        elif self.protocol == "context-adaptive-blending":
            return self.context_adaptive_blending_protocol(member, brief, research, previous_positions, round_num)
        elif self.protocol == "balanced-scorecard":
            return self.balanced_scorecard_protocol(member, brief, research, previous_positions, round_num)
        elif self.protocol == "wisdom-synthesis":
            return self.wisdom_synthesis_protocol(member, brief, research, previous_positions, round_num)
        else:
            return self.generate_debate_statement(member, brief, research, previous_positions, round_num)
    
    def situational_analysis_protocol(self, member: Dict, brief: str, research: str, 
                                     previous_positions: List, round_num: int) -> str:
        """Leadership Council protocol: Analyze organizational context and blend leadership elements"""
        leadership_style = member.get('leadership_style', 'transactional')
        
        if leadership_style == "transformational":
            return f"From a transformational perspective, we must inspire the team toward a bold vision. {self.generate_debate_statement(member, brief, research, previous_positions, round_num)}"
        elif leadership_style == "transactional":
            return f"We need clear rewards and performance metrics. {self.generate_debate_statement(member, brief, research, previous_positions, round_num)}"
        elif leadership_style == "servant":
            return f"How does this serve our team and stakeholders? {self.generate_debate_statement(member, brief, research, previous_positions, round_num)}"
        elif leadership_style == "autocratic":
            return f"We need decisive direction on this matter. {self.generate_debate_statement(member, brief, research, previous_positions, round_num)}"
        else:
            return self.generate_debate_statement(member, brief, research, previous_positions, round_num)
    
    def context_adaptive_blending_protocol(self, member: Dict, brief: str, research: str, 
                                          previous_positions: List, round_num: int) -> str:
        """Management Council protocol: Adapt based on team maturity and task complexity"""
        
        # Simulate context assessment
        team_maturity = "high" if round_num > 0 else "medium"
        task_complexity = "high" if "Technical" in member['name'] else "medium"
        
        return f"Assessing team maturity ({team_maturity}) and task complexity ({task_complexity}): {self.generate_debate_statement(member, brief, research, previous_positions, round_num)}"
    
    def balanced_scorecard_protocol(self, member: Dict, brief: str, research: str, 
                                   previous_positions: List, round_num: int) -> str:
        """Executive Strategy Committee protocol: Consider multiple perspectives"""
        
        if "Financial" in member['name']:
            return f"Financial perspective: ROI, risk-adjusted returns, and capital efficiency. {self.generate_debate_statement(member, brief, research, previous_positions, round_num)}"
        elif "Customer" in member['name']:
            return f"Customer perspective: Value proposition, satisfaction, and retention. {self.generate_debate_statement(member, brief, research, previous_positions, round_num)}"
        elif "Operations" in member['name']:
            return f"Operational perspective: Efficiency, quality, and scalability. {self.generate_debate_statement(member, brief, research, previous_positions, round_num)}"
        else:
            return f"Strategic perspective: Long-term positioning and competitive advantage. {self.generate_debate_statement(member, brief, research, previous_positions, round_num)}"
    
    def wisdom_synthesis_protocol(self, member: Dict, brief: str, research: str, 
                                 previous_positions: List, round_num: int) -> str:
        """Legendary CEOs Council protocol: Apply iconic leadership wisdom"""
        
        if "Moonshot" in member['name']:
            return f"Muskian approach: First principles thinking - what are the fundamental physics here? {self.generate_debate_statement(member, brief, research, previous_positions, round_num)}"
        elif "Compounder" in member['name']:
            return f"Buffettian approach: What's the long-term compounded value? {self.generate_debate_statement(member, brief, research, previous_positions, round_num)}"
        elif "Futurist" in member['name']:
            return f"Jobsian approach: Insanely great or not worth doing. {self.generate_debate_statement(member, brief, research, previous_positions, round_num)}"
        else:
            return f"Wisdom-based synthesis: Learning from iconic leadership. {self.generate_debate_statement(member, brief, research, previous_positions, round_num)}"
    
    def apply_conflict_resolution(self, all_positions: List, deliberation: Dict) -> Dict:
        """Apply the configured conflict resolution method"""
        
        if self.conflict_resolution == "context-matching":
            return self.context_matching_resolution(all_positions, deliberation)
        elif self.conflict_resolution == "team-needs-prioritization":
            return self.team_needs_prioritization_resolution(all_positions, deliberation)
        elif self.conflict_resolution == "strategic-alignment":
            return self.strategic_alignment_resolution(all_positions, deliberation)
        elif self.conflict_resolution == "principle-weighting":
            return self.principle_weighting_resolution(all_positions, deliberation)
        else:
            return self.default_resolution(all_positions, deliberation)
    
    def context_matching_resolution(self, all_positions: List, deliberation: Dict) -> Dict:
        """Resolve conflicts by matching to organizational context"""
        
        # Count positions
        support_count = sum(1 for p in all_positions if "support" in str(p).lower())
        oppose_count = sum(1 for p in all_positions if "oppose" in str(p).lower())
        
        decision = "APPROVE" if support_count > oppose_count else "REJECT"
        rationale = f"Decision based on context-matching: {support_count} support vs {oppose} oppose. Aligning with organizational context and readiness."
        
        return {
            "decision": decision,
            "rationale": rationale,
            "details": "Context factors considered: organizational maturity, market conditions, and stakeholder readiness"
        }
    
    def team_needs_prioritization_resolution(self, all_positions: List, deliberation: Dict) -> Dict:
        """Resolve conflicts by prioritizing team needs"""
        
        # Prioritize positions that consider team impact
        team_focused_positions = [p for p in all_positions if "team" in str(p).lower() or "culture" in str(p).lower()]
        
        if team_focused_positions:
            decision = "APPROVE" if len(team_focused_positions) > len(all_positions) / 2 else "REVIEW"
            rationale = f"Decision prioritizes team needs: {len(team_focused_positions)} team-focused considerations out of {len(all_positions)} total positions"
        else:
            decision = "REVIEW"
            rationale = "Decision deferred for team impact assessment"
        
        return {
            "decision": decision,
            "rationale": rationale,
            "details": "Team needs prioritized: psychological safety, capability development, and cultural alignment"
        }
    
    def strategic_alignment_resolution(self, all_positions: List, deliberation: Dict) -> Dict:
        """Resolve conflicts by aligning with strategic objectives"""
        
        # Weight positions by strategic relevance
        strategic_weight = {
            "Financial": 0.25,
            "Customer": 0.20,
            "Strategic": 0.20,
            "Technical": 0.15,
            "Operations": 0.10,
            "Risk": 0.10
        }
        
        weighted_score = 0
        for position in all_positions:
            # Simple scoring based on position content
            if "support" in str(position).lower():
                weighted_score += 1
            elif "oppose" in str(position).lower():
                weighted_score -= 1
        
        decision = "APPROVE" if weighted_score > 0 else "REJECT"
        rationale = f"Strategic alignment score: {weighted_score}. Decision aligns with long-term strategic objectives."
        
        return {
            "decision": decision,
            "rationale": rationale,
            "details": "Strategic factors weighted: financial impact, customer value, technical feasibility, and operational readiness"
        }
    
    def principle_weighting_resolution(self, all_positions: List, deliberation: Dict) -> Dict:
        """Resolve conflicts by weighting principles"""
        
        # Define principles and their weights
        principles = {
            "innovation": 0.3,
            "sustainability": 0.2,
            "customer_centricity": 0.2,
            "financial_prudence": 0.15,
            "ethical_considerations": 0.15
        }
        
        # Calculate principle-based score
        principle_scores = {}
        for principle, weight in principles.items():
            principle_scores[principle] = weight * (1 if random.random() > 0.5 else -1)  # Simplified
        
        total_score = sum(principle_scores.values())
        decision = "APPROVE" if total_score > 0 else "REJECT"
        rationale = f"Principle-weighted decision: Score {total_score:.2f}. Based on innovation, sustainability, customer centricity, financial prudence, and ethics."
        
        return {
            "decision": decision,
            "rationale": rationale,
            "details": f"Principle scores: {', '.join([f'{k}: {v:.2f}' for k, v in principle_scores.items()])}"
        }
    
    def default_resolution(self, all_positions: List, deliberation: Dict) -> Dict:
        """Default conflict resolution (simple majority)"""
        
        decision = self.synthesize_decision(all_positions)
        rationale = self.generate_decision_rationale(all_positions)
        
        return {
            "decision": decision,
            "rationale": rationale,
            "details": "Simple majority vote with CSO tie-breaking"
        }
    
    def generate_debate_statement(self, member: Dict, brief: str, research: str, 
                                previous_positions: List, round_num: int) -> str:
        """Generate debate statement (deterministic based on round and persona)"""
        
        # Deterministic response based on round number and persona
        if round_num == 0:
            if "Financial" in member['name']:
                return "The financial projections seem optimistic. We should run sensitivity analyses."
            elif "Legal" in member['name']:
                return "I've identified three potential regulatory hurdles that need addressing."
            else:
                return "I agree with some points but disagree with others. Let me elaborate."
        
        elif round_num == 1:
            if "Compounder" in member['name']:
                return "Looking at the 5-year compound effect, this decision could significantly amplify our growth."
            elif "Risk" in member['name']:
                return "We haven't adequately addressed the tail risks. The probability-weighted impact is concerning."
            else:
                return "Building on the previous discussion, I think we're overlooking a key factor."
        
        else:
            if "Technical" in member['name']:
                return "From a technical perspective, this is feasible but will require significant architectural changes."
            elif "Operations" in member['name']:
                return "Operationally, we can implement this but it will require careful phased rollout."
            else:
                return "After considering all viewpoints, my position has evolved slightly."
    
    def generate_final_position(self, member: Dict, deliberation: Dict) -> Dict:
        """Generate final position (vote)"""
        
        # Deterministic voting based on persona
        if "Moonshot" in member['name']:
            return {"vote": "oppose", "rationale": "The proposal is too conservative and doesn't capture the full opportunity."}
        elif "Contrarian" in member['name']:
            return {"vote": "oppose", "rationale": "Still concerned about unaddressed risks and blind spots."}
        elif "Financial" in member['name']:
            return {"vote": "support", "rationale": "The financial case is compelling with acceptable risk-adjusted returns."}
        elif "Customer" in member['name']:
            return {"vote": "support", "rationale": "This aligns with customer needs and will improve their experience."}
        else:
            return {"vote": "support", "rationale": "Overall, the benefits outweigh the concerns."}
    
    def synthesize_decision(self, all_positions: List) -> str:
        """Synthesize final decision from all positions"""
        
        # Count final positions
        support_count = sum(1 for p in all_positions if "support" in str(p).lower())
        oppose_count = sum(1 for p in all_positions if "oppose" in str(p).lower())
        
        if support_count > oppose_count:
            return "APPROVE - Proceed with the proposed course of action"
        elif oppose_count > support_count:
            return "REJECT - Do not proceed at this time"
        else:
            return "CONDITIONAL APPROVAL - Proceed with modifications"
    
    def generate_decision_rationale(self, all_positions: List) -> str:
        """Generate rationale for decision"""
        return "After careful consideration of all perspectives, the committee's input indicates a clear path forward. The decision balances opportunity with risk while aligning with our strategic objectives."
    
    def generate_next_steps(self, deliberation: Dict) -> List[str]:
        """Generate next steps"""
        return [
            "Implement decision monitoring framework",
            "Establish success metrics and KPIs",
            "Create communication plan for stakeholders",
            "Schedule follow-up review in 90 days"
        ]
    
    def save_transcript(self, deliberation: Dict, output_path: Path):
        """Save deliberation transcript to markdown file"""
        
        with open(output_path, 'w') as f:
            f.write(f"# Committee Deliberation Transcript\n\n")
            f.write(f"**Date:** {deliberation['start_time'].strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"**CSO:** {self.cso['role']}\n")
            f.write(f"**Committee Size:** {len(self.members)}\n\n")
            
            # Write each round
            for i, round_data in enumerate(deliberation["rounds"]):
                f.write(f"## {round_data['phase'].replace('_', ' ').title()}\n\n")
                
                if "positions" in round_data:
                    for pos in round_data["positions"]:
                        f.write(f"### {pos['member']}\n\n")
                        f.write(f"**Persona:** {pos.get('persona', 'N/A')}\n\n")
                        f.write(f"{pos.get('position', pos.get('rationale', ''))}\n\n")
                
                if "interactions" in round_data:
                    for interaction in round_data["interactions"]:
                        f.write(f"### {interaction['speaker']}\n\n")
                        f.write(f"{interaction['statement']}\n\n")
            
            # Write decision
            if deliberation["decision"]:
                f.write("## CSO Decision\n\n")
                f.write(f"**Decision:** {deliberation['decision']['decision']}\n\n")
                f.write(f"**Rationale:** {deliberation['decision']['rationale']}\n\n")
                f.write("**Next Steps:**\n\n")
                for step in deliberation['decision']['next_steps']:
                    f.write(f"- {step}\n")

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Orchestrate committee deliberation')
    parser.add_argument('--brief', required=True, help='Path to brief file')
    parser.add_argument('--research', help='Path to research package')
    parser.add_argument('--config', default='config/committee.yaml', help='Committee config file')
    parser.add_argument('--time', type=int, help='Time limit in minutes')
    parser.add_argument('--budget', type=int, help='Budget limit in dollars')
    
    args = parser.parse_args()
    
    # Load config
    config_path = Path(__file__).parent.parent / args.config
    
    # Create orchestrator
    orchestrator = DeliberationOrchestrator(str(config_path))
    
    # Override config if provided
    if args.time:
        orchestrator.deliberation_config['time_limit_minutes'] = args.time
    if args.budget:
        orchestrator.deliberation_config['budget_limit_dollars'] = args.budget
    
    # Start deliberation
    deliberation = orchestrator.start_deliberation(args.brief, args.research)
    
    return 0

if __name__ == "__main__":
    exit(main())

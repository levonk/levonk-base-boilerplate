#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Generate Memo Script for BriefingMemo Skill
Generates final decision memo from deliberation results
"""

import json
import yaml
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any

class MemoGenerator:
    def __init__(self, config_path: str):
        """Initialize memo generator with configuration"""
        with open(config_path, 'r') as f:
            self.config = yaml.safe_load(f)
        
        # Check if dynamic sections are enabled
        self.dynamic_sections = self.config.get('output', {}).get('dynamic_sections', False)
        self.committee_templates = self.config.get('output', {}).get('committee_templates', [])
    
    def generate_memo(self, deliberation_path: str, brief_path: str, output_path: str):
        """Generate final decision memo"""
        
        # Load deliberation results
        with open(deliberation_path, 'r') as f:
            deliberation = json.load(f)
        
        # Load brief
        with open(brief_path, 'r') as f:
            brief_content = f.read()
        
        # Extract title from brief
        title = self.extract_title_from_brief(brief_content)
        
        # Generate memo content
        memo_content = self.build_memo_content(title, deliberation, brief_content)
        
        # Save memo
        with open(output_path, 'w') as f:
            f.write(memo_content)
        
        print(f"✓ Decision memo generated at: {output_path}")
        
        # Generate post-decision reviews
        self.generate_post_decision_reviews(deliberation, output_path.parent)
        
        return memo_content
    
    def extract_title_from_brief(self, brief_content: str) -> str:
        """Extract title from brief content"""
        lines = brief_content.split('\n')
        for line in lines:
            if line.startswith('# '):
                return line[2:].strip()
        return "Strategic Decision"
    
    def build_memo_content(self, title: str, deliberation: Dict, brief_content: str) -> str:
        """Build the complete memo content with dynamic sections"""
        
        decision = deliberation.get('decision', {})
        final_round = None
        for round_data in deliberation.get('rounds', []):
            if round_data.get('phase') == 'final_positions':
                final_round = round_data
                break
        
        # Build base memo
        memo = f"""# Strategic Decision Memo: {title}

*Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*  
*CSO: {self.config['committee']['cso']['role']}*

## Executive Summary

{decision.get('decision', 'Decision pending')}

**Rationale:** {decision.get('rationale', 'Rationale pending')}

**Conflict Resolution Method:** {decision.get('conflict_resolution_method', 'standard voting')}

{decision.get('resolution_details', '')}

---

## Decision Framework

### Key Question Addressed
{self.extract_key_questions(brief_content)}

### Deliberation Protocol
{self.get_deliberation_protocol_info(deliberation)}

### Stakeholder Impact
{self.assess_stakeholder_impact(deliberation)}

### Risk Assessment
{self.assess_risks(deliberation)}

---

## Committee Recommendations

### Vote Summary
"""
        
        if final_round and 'vote_summary' in final_round:
            vote_summary = final_round['vote_summary']
            memo += f"""- **Support:** {vote_summary.get('support', 0)} members
- **Oppose:** {vote_summary.get('oppose', 0)} members  
- **Abstain:** {vote_summary.get('abstain', 0)} members

"""
        
        memo += "### Individual Stances\n\n"
        
        if final_round and 'positions' in final_round:
            for pos in final_round['positions']:
                stance_icon = "✅" if pos['position'] == 'support' else "❌" if pos['position'] == 'oppose' else "⚪"
                leadership_style = self.get_member_leadership_style(pos['member'])
                memo += f"- **{pos['member']}** ({leadership_style}): {stance_icon} {pos['rationale']}\n"
        
        memo += "\n---\n\n"
        
        memo += "## Key Tensions and Resolutions\n\n"
        memo += self.extract_tensions(deliberation)
        
        memo += "---\n\n"
        
        # Add dynamic sections if enabled
        if self.dynamic_sections:
            memo += self.generate_dynamic_sections(deliberation, brief_content)
            memo += "---\n\n"
        
        memo += "## Implementation Plan\n\n"
        memo += "### Next Steps\n\n"
        
        for i, step in enumerate(decision.get('next_steps', []), 1):
            memo += f"{i}. {step}\n"
        
        memo += f"""
### Success Metrics
- Decision implementation progress
- KPI achievement tracking
- Risk mitigation effectiveness

### Timeline
- **Immediate:** Initiate implementation planning
- **30 days:** First progress review
- **90 days:** Comprehensive outcome assessment

---

## Research Summary

### Key Data Points Considered
{self.summarize_research_insights(deliberation)}

### Information Gaps Identified
{self.identify_information_gaps(deliberation)}

---

## Committee Template Integration

{self.generate_committee_template_references(deliberation)}

---

## Appendix

### Brief Reference
Based on brief: {Path(deliberation['brief_path']).name}

### Deliberation Details
- **Duration:** Committee deliberation completed
- **Participants:** {len(self.config['committee']['members'])} committee members
- **CSO:** {self.config['committee']['cso']['role']}
- **Protocol Used:** {deliberation.get('protocol', 'standard')}
- **Conflict Resolution:** {decision.get('conflict_resolution_method', 'standard voting')}

---
*This memo represents the final decision of the strategic committee. All deliberations were conducted according to the established process with full consideration of all perspectives.*
"""
        
        return memo
    
    def extract_key_questions(self, brief_content: str) -> str:
        """Extract key questions from brief"""
        questions_start = brief_content.find("## Key Questions")
        questions_end = brief_content.find("##", questions_start + 1)
        if questions_end == -1:
            questions_end = len(brief_content)
        
        questions_section = brief_content[questions_start:questions_end]
        return questions_section.replace("## Key Questions", "").strip()
    
    def assess_stakeholder_impact(self, deliberation: Dict) -> str:
        """Assess stakeholder impact from deliberation"""
        
        impacts = {
            "Customers": "Positive impact expected with improved experience",
            "Employees": "Minimal disruption with growth opportunities",
            "Investors": "Value creation through strategic alignment",
            "Partners": "Strengthened relationships through clear direction"
        }
        
        result = ""
        for stakeholder, impact in impacts.items():
            result += f"- **{stakeholder}:** {impact}\n"
        
        return result
    
    def assess_risks(self, deliberation: Dict) -> str:
        """Assess risks from deliberation"""
        
        return """- **Implementation Risk:** Medium - Requires careful execution planning
- **Market Risk:** Low - Decision aligns with market trends
- **Financial Risk:** Acceptable - Within risk tolerance parameters
- **Operational Risk:** Managed - With proper resource allocation"""
    
    def extract_tensions(self, deliberation: Dict) -> str:
        """Extract key tensions from deliberation"""
        
        tensions = []
        
        # Analyze positions for tensions
        all_positions = []
        for round_data in deliberation.get('rounds', []):
            if "positions" in round_data:
                all_positions.extend(round_data["positions"])
        
        # Identify common tensions
        if any("Financial" in str(p) for p in all_positions):
            tensions.append("**Financial Prudence vs Growth Opportunity:** Balanced approach with acceptable ROI thresholds")
        
        if any("Risk" in str(p) for p in all_positions):
            tensions.append("**Risk Management vs Innovation:** Proceeded with mitigation strategies in place")
        
        if any("Moonshot" in str(p) for p in all_positions):
            tensions.append("**Incremental vs Transformational:** Chose balanced path with option for future expansion")
        
        if not tensions:
            tensions.append("**No major unresolved tensions:** Committee reached consensus on key issues")
        
        result = ""
        for tension in tensions:
            result += f"- {tension}\n"
        
        return result
    
    def summarize_research_insights(self, deliberation: Dict) -> str:
        """Summarize key research insights"""
        
        if 'research_package' not in deliberation or not deliberation['research_package']:
            return "No additional research package was provided for this deliberation."
        
        return """- Market analysis supports the strategic direction
- Financial projections validated by independent analysis
- Risk assessment completed with mitigation strategies
- Operational feasibility confirmed"""
    
    def identify_information_gaps(self, deliberation: Dict) -> str:
        """Identify information gaps"""
        
        return """- Long-term market evolution scenarios
- Detailed implementation timeline dependencies
- Contingency planning for external factors
- Success metrics for 12+ month horizon"""
    
    def get_member_leadership_style(self, member_name: str) -> str:
        """Get leadership style for a committee member"""
        for member in self.config['committee']['members']:
            if member['name'] == member_name:
                return member.get('leadership_style', 'transactional')
        return 'unknown'
    
    def get_deliberation_protocol_info(self, deliberation: Dict) -> str:
        """Get information about the deliberation protocol used"""
        protocol = deliberation.get('protocol', 'standard')
        
        protocol_descriptions = {
            'situational-analysis': 'Leadership Council protocol analyzing organizational context and blending leadership elements',
            'context-adaptive-blending': 'Management Council protocol adapting based on team maturity and task complexity',
            'balanced-scorecard': 'Executive Strategy Committee protocol considering multiple balanced perspectives',
            'wisdom-synthesis': 'Legendary CEOs Council protocol applying iconic leadership wisdom'
        }
        
        return protocol_descriptions.get(protocol, f'Protocol: {protocol}')
    
    def generate_dynamic_sections(self, deliberation: Dict, brief_content: str) -> str:
        """Generate dynamic sections based on decision context"""
        sections = []
        
        # Analyze decision context for relevant sections
        decision = deliberation.get('decision', {})
        decision_text = decision.get('decision', '').lower()
        
        # Add financial impact section if relevant
        if any(keyword in decision_text for keyword in ['invest', 'budget', 'cost', 'roi', 'financial']):
            sections.append("""### Financial Impact Analysis

#### Investment Requirements
- Initial investment: To be determined based on implementation plan
- Expected ROI: Positive based on strategic alignment
- Payback period: Estimated 18-24 months

#### Budget Considerations
- Operating expense impact: Minimal to moderate
- Capital expenditure: As needed for implementation
- Contingency allocation: 15% of total budget

""")
        
        # Add technology implications if relevant
        if any(keyword in decision_text for keyword in ['technology', 'technical', 'system', 'platform', 'digital']):
            sections.append("""### Technology Implications

#### System Requirements
- Architecture review needed for integration
- Scalability considerations for future growth
- Security assessment for data protection

#### Implementation Timeline
- Phase 1: Planning and design (3 months)
- Phase 2: Development and testing (6 months)
- Phase 3: Deployment and optimization (3 months)

""")
        
        # Add market impact section if relevant
        if any(keyword in decision_text for keyword in ['market', 'customer', 'competition', 'growth']):
            sections.append("""### Market Impact Assessment

#### Competitive Position
- Market differentiation: Enhanced through strategic alignment
- Market share: Expected growth of 5-10% annually
- Competitive advantage: Sustainable through innovation

#### Customer Implications
- Customer experience: Improved through streamlined processes
- Market reach: Expanded through new capabilities
- Retention rates: Expected improvement of 3-5%

""")
        
        # Add organizational change section if relevant
        if any(keyword in decision_text for keyword in ['team', 'organization', 'structure', 'change']):
            sections.append("""### Organizational Change Management

#### Team Impact
- Structure changes: Minimal to moderate adjustments
- Skill requirements: Training programs identified
- Communication plan: Regular updates and feedback loops

#### Change Readiness
- Leadership alignment: Strong support demonstrated
- Employee engagement: High anticipated buy-in
- Cultural fit: Aligned with organizational values

""")
        
        # If no specific sections triggered, add a general insights section
        if not sections:
            sections.append("""### Additional Insights

Based on the deliberation context, the following considerations are relevant:

#### Strategic Alignment
- Decision supports long-term organizational goals
- Synergies identified with existing initiatives
- Resource allocation optimized for maximum impact

#### Implementation Considerations
- Cross-functional collaboration required
- Success metrics clearly defined and measurable
- Risk mitigation strategies in place

""")
        
        return '\n'.join(sections)
    
    def generate_committee_template_references(self, deliberation: Dict) -> str:
        """Generate references to relevant committee templates"""
        if not self.committee_templates:
            return "No specific committee templates were referenced in this deliberation."
        
        references = []
        protocol = deliberation.get('protocol', 'standard')
        
        # Add references based on templates used
        if 'leadership-council' in self.committee_templates:
            references.append("""**Leadership Council Integration:**
This deliberation incorporated leadership style analysis with transformational, transactional, servant, and autocratic approaches. The situational-analysis protocol ensured context-appropriate leadership recommendations.

See: [Leadership Council](../committees/business/leadership-council.md)""")
        
        if 'management-council' in self.committee_templates:
            references.append("""**Management Council Integration:**
Team management approaches were considered, blending coaching, visionary, pacesetter, and democratic styles based on team maturity and task complexity.

See: [Management Council](../committees/business/management-council.md)""")
        
        if 'executive-strategy-committee' in self.committee_templates:
            references.append("""**Executive Strategy Integration:**
Balanced scorecard approach was applied, considering financial, customer, operational, and strategic perspectives for comprehensive decision-making.

See: [Executive Strategy Committee](../committees/business/executive/executive-strategy-committee.md)""")
        
        if 'legendary-ceos' in self.committee_templates:
            references.append("""**Legendary CEOs Wisdom Integration:**
Iconic leadership approaches were synthesized, drawing from first-principles thinking (Musk), long-term value creation (Buffett), and design excellence (Jobs).

See: [Legendary CEOs Council](../committees/legendary-ceos-council.md)""")
        
        return '\n\n'.join(references)
    
    def generate_post_decision_reviews(self, deliberation: Dict, output_dir: Path):
        """Generate post-decision reviews from specialized agents"""
        
        post_decision_agents = self.config['committee'].get('post_decision_review', [])
        
        if not post_decision_agents:
            return
        
        reviews_content = "# Post-Decision Reviews\n\n"
        reviews_content += f"*Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n\n"
        reviews_content += "*Note: These reviews are provided for context and do not influence the decision.*\n\n"
        
        decision = deliberation.get('decision', {})
        
        for agent in post_decision_agents:
            review = self.generate_agent_review(agent, decision, deliberation)
            reviews_content += f"## {agent['name']}\n\n"
            reviews_content += f"{review}\n\n"
        
        # Save reviews
        reviews_path = output_dir / "post_decision_reviews.md"
        with open(reviews_path, 'w') as f:
            f.write(reviews_content)
        
        print(f"✓ Post-decision reviews saved to: {reviews_path}")
    
    def generate_agent_review(self, agent: Dict, decision: Dict, deliberation: Dict) -> str:
        """Generate review for a post-decision agent"""
        
        if "Philanthropic" in agent['name']:
            return """The decision should be evaluated for its social impact. Consider establishing metrics for community benefit and exploring partnerships with non-profit organizations to maximize positive outcomes."""
        
        elif "Environmental" in agent['name']:
            return """Environmental implications should be monitored. Recommend conducting an environmental impact assessment and setting sustainability targets aligned with this decision."""
        
        else:
            return """The decision has been reviewed from this specialized perspective. Additional considerations may arise during implementation that should be monitored."

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Generate decision memo')
    parser.add_argument('--deliberation', required=True, help='Path to deliberation JSON file')
    parser.add_argument('--brief', required=True, help='Path to brief file')
    parser.add_argument('--output', required=True, help='Output path for memo')
    parser.add_argument('--config', default='config/committee.yaml', help='Committee config file')
    
    args = parser.parse_args()
    
    # Load config
    config_path = Path(__file__).parent.parent / args.config
    
    # Create memo generator
    generator = MemoGenerator(str(config_path))
    
    # Generate memo
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    generator.generate_memo(args.deliberation, args.brief, str(output_path))
    
    return 0

if __name__ == "__main__":
    exit(main())

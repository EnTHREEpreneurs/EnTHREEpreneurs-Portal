import { configured, supabase } from "./supabase-app.js";
const fallback=window.ENTHREE_DATA||{subjects:[]};
const esc=v=>String(v??"").replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#039;'}[c]));
async function getCollection(name,sortField="created_at",ascending=false){
  if(!configured)return [];
  try{const {data,error}=await supabase.from(name).select('*').order(sortField,{ascending}); if(error)throw error; return data||[];}catch{return [];}
}
async function subjects(){const s=await getCollection("subjects","name",true);const active=s.filter(x=>x.active!==false);return active.length?active:fallback.subjects;}
async function renderFunds(){
 const table=document.getElementById("fundTable"),balanceEl=document.getElementById("fundBalance"); if(!table||!balanceEl)return;
 const rows=(await getCollection("funds","date",true)); let balance=0;
 table.innerHTML=rows.length?rows.map(x=>{balance+=Number(x.income||0)-Number(x.expense||0);const receipt=x.receipt_url?`<a class="text-link" href="${esc(x.receipt_url)}" target="_blank" rel="noopener">Receipt →</a>`:"—";return `<tr><td>${esc(x.date||"—")}</td><td>${esc(x.description||"")}</td><td>${x.income?"₱"+Number(x.income).toFixed(2):"—"}</td><td>${x.expense?"₱"+Number(x.expense).toFixed(2):"—"}</td><td>₱${balance.toFixed(2)}</td><td>${receipt}</td></tr>`}).join(""):`<tr><td colspan="6">No transactions have been added yet.</td></tr>`;
 balanceEl.textContent="₱"+balance.toLocaleString("en-PH",{minimumFractionDigits:2});
}
async function render(){
 const list=await subjects();
 const rc=document.getElementById("resourceSubjects"),ac=document.getElementById("activitySubjects"),count=document.getElementById("subjectCount");
 if(count)count.textContent=`${list.length} Subjects`;
 const card=(s,type)=>`<article class="subject-card"><div class="subject-icon">${s.icon||"📚"}</div><h3>${esc(s.name)}</h3><p>${esc(s.description||"")}</p><a href="pages/subject.html?subjectId=${encodeURIComponent(s.id||"")}&subject=${encodeURIComponent(s.name)}&type=${type}">Open ${type==="activities"?"activities":"resources"} →</a></article>`;
 if(rc)rc.innerHTML=list.map(s=>card(s,"resources")).join(""); if(ac)ac.innerHTML=list.map(s=>card(s,"activities")).join("");
 const rows=await getCollection("announcements","created_at",false),ann=document.getElementById("announcementList");
 if(ann){ann.innerHTML=rows.slice(0,3).map(a=>`<article class="announcement-card"><span class="announcement-dot">●</span><div><small>${esc(a.date||"Announcement")}</small><h3>${esc(a.title)}</h3><p>${esc(a.message||"")}</p></div></article>`).join("")||`<div class="empty">No announcements yet.</div>`;}
 await renderFunds();
}
render();
